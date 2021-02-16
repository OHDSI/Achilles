-- 724
-- For each drug concept, find and rank the top 10 co-occurring drug concepts.
--

-- HINT DISTRIBUTE_ON_KEY(stratum_1)
-- Find all drug_concept_id pairs, the number of people with these pairs, 
-- and the number of times these pairs occur.
with pairs as (
select d1.drug_concept_id drug_concept_id_1,
       d2.drug_concept_id drug_concept_id_2,
       count(distinct d2.person_id) num_people,
       count(*) num_cases
  from @cdmDatabaseSchema.drug_exposure d1
  join @cdmDatabaseSchema.drug_exposure d2
    on d1.person_id = d2.person_id
 where d1.drug_concept_id != 0
   and d2.drug_concept_id != 0
   and d1.drug_concept_id != d2.drug_concept_id
 group by d1.drug_concept_id, d2.drug_concept_id
), ranks as (
-- Rank order the pairs by the number of people who have them and use
-- the number of cases as a tie breaker
select drug_concept_id_1, 
       drug_concept_id_2, 
	   num_people,
	   num_cases,
       row_number()over(partition by drug_concept_id_1 order by num_people desc, num_cases desc) ranking
  from pairs
) 
select 724 as analysis_id,
       cast(drug_concept_id_1 as varchar(255)) as stratum_1,
	   cast(drug_concept_id_2 as varchar(255)) as stratum_2,
	   cast(ranking           as varchar(255)) as stratum_3,
	   cast(num_people        as varchar(255)) as stratum_4,
       cast(num_cases         as varchar(255)) as stratum_5,
	   num_people             as count_value		
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_724 
  from ranks 
 where ranking <= 10
;

