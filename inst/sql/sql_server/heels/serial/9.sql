--rule30 CDM-conformance rule: is CDM metadata table created at all?
  --create a derived measure for rule30
  --done strangly to possibly avoid from dual error on Oracle
  --done as not null just in case sqlRender has NOT NULL  hard coded
  --check if table exist and if yes - derive 1 for a derived measure
  
  --does not work on redshift :-( --commenting it out
IF OBJECT_ID('@cdmDatabaseSchema.CDM_SOURCE', 'U') IS NOT NULL
  select 
    null as analysis_id,
    null as stratum_1,
    null as stratum_2,
    distinct analysis_id as statistic_value,
    'MetaData:TblExists' as measure_id
  into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
  from @resultsDatabaseSchema.ACHILLES_results
  where analysis_id = 1;
  
  --actual rule30
  
--end of rule30