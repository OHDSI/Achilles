select *
into #rule27_1
from
(

  select * from @schema@schemaDelimachilles_rd_0
  
  union all
  
  select
    cast(null as int) as analysis_id,
    CAST('Condition' AS VARCHAR(255)) as stratum_1, 
    cast(null as varchar(255)) as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST('UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from @schema@schemaDelimachilles_rd_0
  cross join (select statistic_value as val from @schema@schemaDelimachilles_rd_0
      where measure_id like 'UnmappedData:ach_401:GlobalRowCnt') as st
  where measure_id = 'ach_401:GlobalRowCnt'
) Q
;


select *
into #rule27_2
from
(

  select * from #rule27_1
  
  union all
  
  select
    cast(null as int) as analysis_id,
    CAST('Procedure' AS VARCHAR(255)) as stratum_1,
    cast(null as varchar(255)) as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
     CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from #rule27_1 A
  cross join (select statistic_value as val from #rule27_1 
        where measure_id = 'UnmappedData:ach_601:GlobalRowCnt') as st
  where measure_id ='ach_601:GlobalRowCnt'
    
) Q
;


select *
into #rule27_3
from
(

  select * from #rule27_2
  
  union all
  
  select
    cast(null as int) as analysis_id,
    CAST('DrugExposure' AS VARCHAR(255)) as stratum_1,
    cast(null as varchar(255)) as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from #rule27_2 A
  cross join (select statistic_value as val from #rule27_2 
        where measure_id = 'UnmappedData:ach_701:GlobalRowCnt') as st
  where measure_id ='ach_701:GlobalRowCnt'
  
) Q
;


select *
into #rule27_4
from
(

  select * from #rule27_3
  
  union all
  
  select
    cast(null as int) as analysis_id,
    CAST('Observation' AS VARCHAR(255)) as stratum_1, 
    cast(null as varchar(255)) as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from #rule27_3 A
  cross join (select statistic_value as val from #rule27_3
        where measure_id = 'UnmappedData:ach_801:GlobalRowCnt') as st
  where measure_id ='ach_801:GlobalRowCnt'
  
) Q
;


select *
into #rule27_5
from
(

  select * from #rule27_4
  
  union all
  
  select
    cast(null as int) as analysis_id,
    CAST('Measurement' AS VARCHAR(255)) as stratum_1, 
    cast(null as varchar(255)) as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from #rule27_4 A
  cross join (select statistic_value as val from #rule27_4
        where measure_id = 'UnmappedData:ach_1801:GlobalRowCnt') as st
  where measure_id ='ach_1801:GlobalRowCnt'
  
) Q
;


select * 
into #serial_rd_@rdNewId
from
(
  select * from #rule27_5
) Q;

truncate table #rule27_1;
drop table #rule27_1;

truncate table #rule27_2;
drop table #rule27_2;

truncate table #rule27_3;
drop table #rule27_3;

truncate table #rule27_4;
drop table #rule27_4;

truncate table #rule27_5;
drop table #rule27_5;


--actual rule27
  
select *
into #serial_hr_@hrNewId
from
(
  select * from @schema@schemaDelimachilles_hr_0
  
  union all
  
  SELECT 
    cast(null as int) as analysis_id,
    CAST(CONCAT('NOTIFICATION:Unmapped data over percentage threshold in:', 
    cast(d.stratum_1 as varchar(100))) AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    27 as rule_id,
    cast(null as bigint) as record_count
  FROM #serial_rd_@rdNewId d
  where d.measure_id = 'UnmappedData:byDomain:Percentage'
  and d.statistic_value > 0.1  --thresholds will be decided in the ongoing DQ-Study2
) Q
;

--end of rule27

drop table @schema@schemaDelimachilles_hr_0;
drop table @schema@schemaDelimachilles_rd_0;
