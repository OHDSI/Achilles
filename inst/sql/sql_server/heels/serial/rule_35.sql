--rule35 DQ rule, NOTIFICATION
--this rule analyzes Units recorded for measurement
select *
into #serial_hr_@hrNewId
from
(
  select * from #serial_hr_@hrOldId
  
  union all
  
  select 
    cast(null as int) as analysis_id,
    achilles_heel_warning,
    rule_id,
    record_count
  from
  (
    SELECT
    CAST('NOTIFICATION: Count of measurement_ids with more than 5 distinct units  exceeds threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    35 as rule_id,
    cast(meas_concept_id_cnt as int) as record_count
    from (
          select meas_concept_id_cnt from (select sum(freq) as meas_concept_id_cnt from
                          (select u_cnt, count(*) as freq from 
                                  (select stratum_1, count(*) as u_cnt
                                      from @resultsDatabaseSchema.achilles_results where analysis_id = 1807 group by stratum_1) a
                                      group by u_cnt
                          ) b 
                  where u_cnt >= 5 --threshold one for the rule
              ) c
             where meas_concept_id_cnt >= 10 --threshold two for the rule
         ) d 
  ) Q
) A
;       