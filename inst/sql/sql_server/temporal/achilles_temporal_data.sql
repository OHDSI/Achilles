
-- Query to return monthly count, prevalence, and proportion (within year) data from Achilles.
-- Depending on the parameters provided, the query will return data for a concept_id or 
-- one or more analysis_ids necessary for temporal characterization.
-- Since this query is specifically for temporal characterization, we exclude unmapped 
-- concepts and concepts with less than three years of data.

  with num as (
select '@db_name' db_name,
       case 
	   when c.domain_id = 'Condition'   then 'CONDITION_OCCURRENCE'
	   when c.domain_id = 'Procedure'   then 'PROCEDURE_OCCURRENCE'
	   when c.domain_id = 'Visit'       then 'VISIT_OCCURRENCE'
	   when c.domain_id = 'Observation' then 'OBSERVATION'
	   when c.domain_id = 'Measurement' then 'MEASUREMENT'
	   when c.domain_id = 'Drug'        then 'DRUG_EXPOSURE'
	   when c.domain_id = 'Device'      then 'DEVICE_EXPOSURE'
	   else 'UNKNOWN'
	   end cdm_table_name,
       c.concept_id,
       c.concept_name,
	   ar.stratum_2,
       1.0*ar.count_value count_value,
       count(*)over(partition by c.concept_id) total
	   
  from @results_schema.achilles_results ar
  join @cdm_schema.concept c on ar.stratum_1  = cast(c.concept_id as varchar)

{@analysis_id_given} ? {where c.concept_id != 0 and ar.analysis_id in (@analysis_ids)}
{@concept_id_given}  ? {where c.concept_id = @concept_id and ar.analysis_id in (202,402,602,702,802,1802,2102)}
{!@analysis_id_given & !@concept_id_given} ? {where c.concept_id != 0 and ar.analysis_id in (202,402,602,702,802,1802,2102)}
)
select num.db_name,
       num.cdm_table_name,
	   num.concept_id,
       num.concept_name,
	   concat(num.stratum_2,'01') start_date,
       num.count_value,
       1000*num.count_value/denom.count_value as prevalence,
	   num.count_value/sum(num.count_value)over(partition by num.concept_id, left(num.stratum_2,4)) proportion_within_year
  from num
  join @results_schema.achilles_results denom
    on num.stratum_2 = denom.stratum_1 and denom.analysis_id = 117
 where num.total >= 36;
