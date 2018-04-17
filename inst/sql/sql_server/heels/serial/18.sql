--ruleid 38 DQ rule; in a general dataset, it is expected that more than providers with a wide range of specialties 
--(at least more than just one specialty) is present
--notification  may indicate that provider table is missing data on specialty 
--typical dataset has at least 28 specialties present in provider table

select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select
    null as analysis_id,
    CAST('NOTIFICATION: [GeneralPopulationOnly] Count of distinct specialties of providers in the PROVIDER table is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    38 as rule_id,
    cast(statistic_value as int) as record_count
  FROM @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId d
  where measure_id = 'Provider:SpeciatlyCnt'
  and statistic_value < 2 --DataQuality data indicate median of 55 specialties (percentile25 is 28; percentile10 is 2)
) Q
;
