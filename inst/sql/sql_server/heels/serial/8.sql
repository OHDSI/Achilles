--rule29 DQ rule
--unusual diagnosis present, this rule is terminology dependend

with tempcnt as(
	select sum(count_value) as pt_cnt from @resultsDatabaseSchema.ACHILLES_results 
	where analysis_id = 404 --dx by decile
	and stratum_1 = '195075' --meconium
	--and stratum_3 = '8507' --possible limit to males only
	and cast(stratum_4 as int) >= 5 --fifth decile or more
)
select pt_cnt as record_count 
into #tempResults
--set threshold here, currently it is zero
from tempcnt where pt_cnt > 0;


--using temp table because with clause that occurs prior insert into is causing problems 
--and with clause makes the code more readable

SELECT *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
FROM 
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select 
    null as analysis_id,
    CAST('WARNING:[PLAUSIBILITY] infant-age diagnosis (195075) at age 50+' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    29 as rule_id,
    null as record_count
  from #tempResults
) Q;

truncate table #tempResults;
drop table #tempResults;
--end of rule29
