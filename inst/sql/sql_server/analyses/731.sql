-- 731 Number and proportion of look forward days by drug_concept_id.
-- NB: Look forward days (stratum_3) are limited to the Atlas defaults: 0,1,7,14,21,30,60,90,120,180,365,548,730,1095.
--     Proportion (stratum_2) represents the proportion of people with a given drug that have at least
--     N days of look forward.

--HINT DISTRIBUTE_ON_KEY(stratum_1)
  with de as (
-- Find earliest occurrence of each concept_id, person_id pair  
select drug_concept_id, person_id, min(drug_exposure_start_date) drug_exposure_start_date
  from @cdmDatabaseSchema.drug_exposure
 group by drug_concept_id,person_id
), lookforward as (
-- Count the concept_id, look forward day pairs 
select de.drug_concept_id,
       datediff(d,de.drug_exposure_start_date,op.observation_period_end_date) as lookforward_days,
       count_big(*) as count_value
  from @cdmDatabaseSchema.observation_period op join de
    on de.person_id = op.person_id
 where op.observation_period_end_date >= de.drug_exposure_start_date
 group by de.drug_concept_id, datediff(d,de.drug_exposure_start_date,op.observation_period_end_date)
), lookforward_prop as (
-- Compute the proportion of people with N days of look forward per concept_id
select *,
       1.0*sum(count_value)over(
	            partition by drug_concept_id 
				    order by lookforward_days 
	                 rows between current row and unbounded following)/sum(count_value)over() as proportion       
  from lookforward
)
-- To avoid flooding Achilles, limit look forward days to the Atlas defaults
select 731 as analysis_id,
       cast(drug_concept_id        as varchar(255)) as stratum_1,
       cast(proportion             as varchar(255)) as stratum_2,
       cast(lookforward_days       as varchar(255)) as stratum_3,
       cast(null                   as varchar(255)) as stratum_4,
       cast(null                   as varchar(255)) as stratum_5,
       count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_731
  from lookforward_prop 
 where lookforward_days in (0,1,7,14,21,30,60,90,120,180,365,548,730,1095); 
   