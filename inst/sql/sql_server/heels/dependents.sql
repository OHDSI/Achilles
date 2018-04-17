{DEFAULT @ThresholdAgeWarning = 125} 
{DEFAULT @ThresholdOutpatientVisitPerc = 0.43} 
{DEFAULT @ThresholdMinimalPtMeasDxRx = 20.5} 

--rules may require first a derived measure and the subsequent data quality 
--check is simpler to implement
--also results are accessible even if the rule did not generate a warning

--rule27
--due to most likely missint sql cast errors it was removed from this release
--will be included after more testing
--being fixed in this update

--compute derived measure first
insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,stratum_1,measure_id)    
select
  CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
  CAST('Condition' AS VARCHAR(255)) as stratum_1, 
  CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
from @resultsDatabaseSchema.ACHILLES_results_derived 
join (select statistic_value as val
from @resultsDatabaseSchema.achilles_results_derived where measure_id like 'UnmappedData:ach_401:GlobalRowCnt') as st
where measure_id = 'ach_401:GlobalRowCnt';

insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,stratum_1,measure_id)    
select
  CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
  CAST('Procedure' AS VARCHAR(255)) as stratum_1, 
  CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
from @resultsDatabaseSchema.ACHILLES_results_derived
join (select statistic_value as val
from @resultsDatabaseSchema.ACHILLES_results_derived 
where measure_id = 'UnmappedData:ach_601:GlobalRowCnt') as st
where measure_id ='ach_601:GlobalRowCnt';

insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,stratum_1,measure_id)    
select
  CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
  CAST('DrugExposure' AS VARCHAR(255)) as stratum_1, 
  CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
from @resultsDatabaseSchema.ACHILLES_results_derived
join (select statistic_value as val
from @resultsDatabaseSchema.ACHILLES_results_derived where measure_id ='UnmappedData:ach_701:GlobalRowCnt') as st
where measure_id ='ach_701:GlobalRowCnt';

insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,stratum_1,measure_id)    
select
  CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
  CAST('Observation' AS VARCHAR(255)) as stratum_1, 
  CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
from @resultsDatabaseSchema.ACHILLES_results_derived 
join (select statistic_value as val 
from @resultsDatabaseSchema.ACHILLES_results_derived where measure_id ='UnmappedData:ach_801:GlobalRowCnt') as st
where measure_id = 'ach_801:GlobalRowCnt';

insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,stratum_1,measure_id)    
select
CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
  CAST('Measurement' AS VARCHAR(255)) as stratum_1, 
  CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
from @resultsDatabaseSchema.ACHILLES_results_derived 
join (select statistic_value as val
from @resultsDatabaseSchema.ACHILLES_results_derived where measure_id ='UnmappedData:ach_1801:GlobalRowCnt') as st
where measure_id ='ach_1801:GlobalRowCnt';


--actual rule27

  insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
  SELECT 
   CAST(CONCAT('NOTIFICATION:Unmapped data over percentage threshold in:', cast(d.stratum_1 as varchar)) AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    27 as rule_id
  FROM @resultsDatabaseSchema.ACHILLES_results_derived d
  where d.measure_id = 'UnmappedData:byDomain:Percentage'
  and d.statistic_value > 0.1  --thresholds will be decided in the ongoing DQ-Study2
  ;

--end of rule27

--rule28 DQ rule
--are all values (or more than threshold) in measurement table non numerical?
--(count of Measurment records with no numerical value is in analysis_id 1821)



with t1 (all_count) as 
  (select sum(count_value) as all_count from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 1820)
select 
CAST(ct.count_value*CAST(100.0 AS FLOAT)/all_count AS FLOAT) as statistic_value,
	CAST('Meas:NoNumValue:Percentage' AS VARCHAR(100)) as measure_id
into #tempResults 
from t1
join (select CAST(count_value AS FLOAT) as count_value from @resultsDatabaseSchema.achilles_results where analysis_id = 1821) as ct;


insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value, measure_id)    
  select  statistic_value, measure_id from #tempResults;



insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
SELECT 
   CAST('NOTIFICATION: percentage of non-numerical measurement records exceeds general population threshold ' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
	28 as rule_id,
	cast(statistic_value as int) as record_count
FROM #tempResults t
--WHERE t.analysis_id IN (100730,100430) --umbrella version
WHERE measure_id='Meas:NoNumValue:Percentage' --t.analysis_id IN (100000)
--the intended threshold is 1 percent, this value is there to get pilot data from early adopters
	AND t.statistic_value >= 80
;


--clean up temp tables for rule 28
truncate table #tempResults;
drop table #tempResults;

--end of rule 28

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
insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
SELECT 
 CAST('WARNING:[PLAUSIBILITY] infant-age diagnosis (195075) at age 50+' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  29 as rule_id,
  record_count
FROM #tempResults t;

truncate table #tempResults;
drop table #tempResults;
--end of rule29


--rule30 CDM-conformance rule: is CDM metadata table created at all?
  --create a derived measure for rule30
  --done strangly to possibly avoid from dual error on Oracle
  --done as not null just in case sqlRender has NOT NULL  hard coded
  --check if table exist and if yes - derive 1 for a derived measure
  
  --does not work on redshift :-( --commenting it out
--IF OBJECT_ID('@cdmDatabaseSchema.CDM_SOURCE', 'U') IS NOT NULL
--insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,measure_id)    
--  select distinct analysis_id as statistic_value,
--  'MetaData:TblExists' as measure_id
--  from @resultsDatabaseSchema.ACHILLES_results
--  where analysis_id = 1;
  
  --actual rule30
  
--end of rule30


--rule31 DQ rule
--ratio of providers to total patients

--compute a derived reatio
--TODO if provider count is zero it will generate division by zero (not sure how dirrerent db engins will react)
insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,measure_id)    
    select CAST(1.0*ct.total_pts/count_value AS FLOAT) as statistic_value, CAST('Provider:PatientProviderRatio' AS VARCHAR(255)) as measure_id
    from @resultsDatabaseSchema.achilles_results
		join (select count_value as total_pts from @resultsDatabaseSchema.achilles_results r where analysis_id =1) ct
		where analysis_id = 300
;

--actual rule
insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
SELECT 
 CAST('NOTIFICATION:[PLAUSIBILITY] database has too few providers defined (given the total patient number)' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  31 as rule_id
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where d.measure_id = 'Provider:PatientProviderRatio'
and d.statistic_value > 10000  --thresholds will be decided in the ongoing DQ-Study2
;

--rule32 DQ rule
--uses iris: patients with at least one visit visit 
--does 100-THE IRIS MEASURE to check for percentage of patients with no visits

insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
SELECT 
 CAST('NOTIFICATION: Percentage of patients with no visits exceeds threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  32 as rule_id
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where d.measure_id = 'ach_2003:Percentage'
and 100-d.statistic_value > 27  --threshold identified in the DataQuality study
;

--rule33 DQ rule (for general population only)
--NOTIFICATION: database does not have all age 0-80 represented


insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
SELECT 
 CAST('NOTIFICATION: [GeneralPopulationOnly] Not all deciles represented at first observation' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  33 as rule_id
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where d.measure_id = 'AgeAtFirstObsByDecile:DecileCnt' 
and d.statistic_value <9  --we expect deciles 0,1,2,3,4,5,6,7,8 
;

 
--rule34 DQ rule
--NOTIFICATION: number of unmapped source values exceeds threshold
--related to rule 27 that looks at percentage of unmapped rows (rows as focus)
--this rule is looking at source values (as focus)


insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
SELECT 
 CAST(CONCAT('NOTIFICATION: Count of unmapped source values exceeds threshold in: ', cast(stratum_1 as varchar)) AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  34 as rule_id,
  cast(statistic_value as int) as record_count
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where measure_id = 'UnmappedDataByDomain:SourceValueCnt'
and statistic_value > 1000; --threshold will be decided in DQ study 2



--rule35 DQ rule, NOTIFICATION
--this rule analyzes Units recorded for measurement

insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
 SELECT
 CAST('NOTIFICATION: Count of measurement_ids with more than 5 distinct units  exceeds threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  35 as rule_id,
  cast(meas_concept_id_cnt as int) as record_count
  from (
        select meas_concept_id_cnt from (select sum(freq) as meas_concept_id_cnt from
                        (select u_cnt, count(*) as freq from 
                                (select stratum_1, count(*) as u_cnt
                                    from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 1807 group by stratum_1) a 
                                    group by u_cnt
                        ) b 
                where u_cnt >= 5 --threshold one for the rule
            ) c
           where meas_concept_id_cnt >= 10 --threshold two for the rule
       ) d 
;       



--ruleid 36 WARNING: age > 125   (related to an error grade rule 21 that has higher threshold)
insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
	)
SELECT or1.analysis_id,
	CAST(CONCAT('WARNING: ', cast(or1.analysis_id as VARCHAR), '-', oa1.analysis_name, '; should not have age > @ThresholdAgeWarning, (n=', cast(sum(or1.count_value) as VARCHAR), ')') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
  36 as rule_id,
  sum(or1.count_value) as record_count
FROM @resultsDatabaseSchema.ACHILLES_results or1
INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (101)
	AND CAST(or1.stratum_1 AS INT) > @ThresholdAgeWarning
	AND or1.count_value > 0
GROUP BY or1.analysis_id,
  oa1.analysis_name;

--ruleid 37 DQ rule

--derived measure for this rule - ratio of notes over the number of visits
insert into @resultsDatabaseSchema.ACHILLES_results_derived (statistic_value,measure_id)    
 SELECT CAST(1.0*c1.all_notes/1.0*c2.all_visits AS FLOAT) as statistic_value, CAST(  'Note:NoteVisitRatio' AS VARCHAR(255)) as measure_id
FROM (SELECT sum(count_value) as all_notes FROM	@resultsDatabaseSchema.achilles_results r WHERE analysis_id =2201 ) c1
JOIN (SELECT sum(count_value) as all_visits FROM @resultsDatabaseSchema.achilles_results r WHERE  analysis_id =201 ) c2;


--one co-author of the DataQuality study suggested measuring data density on visit level (in addition to 
-- patient and dataset level)
--Assumption is that at least one data event (e.g., diagnisis, note) is generated for each visit
--this rule is testing that at least some notes exist (considering the number of visits)
--for datasets with zero notes the derived measure is null and rule does not fire at all
--possible elaboration of this rule include number of inpatient notes given number of inpatient visits
--current rule is on overall data density (for notes only) per visit level

insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
SELECT 
 CAST('NOTIFICATION: Notes data density is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  37 as rule_id,
  cast(statistic_value as int) as record_count
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where measure_id = 'Note:NoteVisitRatio'
and statistic_value < 0.01; --threshold will be decided in DataQuality study




--ruleid 38 DQ rule; in a general dataset, it is expected that more than providers with a wide range of specialties 
--(at least more than just one specialty) is present
--notification  may indicate that provider table is missing data on specialty 
--typical dataset has at least 28 specialties present in provider table

insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
SELECT 
 CAST('NOTIFICATION: [GeneralPopulationOnly] Count of distinct specialties of providers in the PROVIDER table is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  38 as rule_id,
  cast(statistic_value as int) as record_count
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where measure_id = 'Provider:SpeciatlyCnt'
and statistic_value <2; --DataQuality data indicate median of 55 specialties (percentile25 is 28; percentile10 is 2)


--ruleid 39 DQ rule; Given lifetime record DQ assumption if more than 30k patients is born for every deceased patient
--the dataset may not be recording complete records for all senior patients in that year
--derived ratio measure Death:BornDeceasedRatio only exists for years where death data exist
--to avoid alerting on too early years such as 1925 where births exist but no deaths

insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id,record_count)
select 
CAST('NOTIFICATION: [GeneralPopulationOnly] In some years, number of deaths is too low considering the number of births (lifetime record DQ assumption)' AS VARCHAR(255))
 as achilles_heel_warning,
 39 as rule_id,
 year_cnt as record_count 
 from
 (select count(*) as year_cnt from @resultsDatabaseSchema.ACHILLES_results_derived 
 where measure_id =  'Death:BornDeceasedRatio' and statistic_value > 30000) a
where a.year_cnt> 0; 


--ruleid 40  this rule was under umbrella rule 1 and was made into a separate rule


insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
	)
SELECT DISTINCT or1.analysis_id,
	CAST(CONCAT('ERROR: Death event outside observation period, ', cast(or1.analysis_id as VARCHAR), '-', oa1.analysis_name, '; count (n=', cast(or1.count_value as VARCHAR), ') should not be > 0') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
	40 as rule_id,
	or1.count_value
FROM @resultsDatabaseSchema.ACHILLES_results or1
INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (510)
	AND or1.count_value > 0;


--ruleid 41 DQ rule, data density
--porting a Sentinel rule that checks for certain vital signs data (weight, in this case)
--multiple concepts_ids may be added to broaden the rule, however standardizing on a single
--concept would be more optimal

insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
select CAST('NOTIFICATION:No body weight data in MEASUREMENT table (under concept_id 3025315 (LOINC code 29463-7))' AS VARCHAR(255))
 as achilles_heel_warning,
 41 as rule_id
from
(select count(*) as row_present  
 from @resultsDatabaseSchema.ACHILLES_results 
 where analysis_id = 1800 and stratum_1 = '3025315'
) a
where a.row_present = 0;



--ruleid 42 DQ rule
--Percentage of outpatient visits (concept_id 9202) is too low (for general population).
--This may indicate a dataset with mostly inpatient data (that may be biased and missing some EHR events)
--Threshold was decided as 10th percentile in empiric comparison of 12 real world datasets in the DQ-Study2



insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
select CAST('NOTIFICATION: [GeneralPopulationOnly] Percentage of outpatient visits is below threshold' AS VARCHAR(255))
 as achilles_heel_warning,
 42 as rule_id
from
 (
  select 
     1.0*achilles_results.count_value/c1.count_value as outp_perc
  from @resultsDatabaseSchema.achilles_results
		join (select sum(count_value) as count_value from @resultsDatabaseSchema.achilles_results where analysis_id = 201) c1
	where analysis_id = 201 and stratum_1='9202'
  ) d
where d.outp_perc < @ThresholdOutpatientVisitPerc;

--ruleid 43 DQ rule
--looks at observation period data, if all patients have exactly one the rule alerts the user
--This rule is based on majority of real life datasets. 
--For some datasets (e.g., UK national data with single payor, one observation period is perfectly valid)


insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
select CAST('NOTIFICATION: 99+ percent of persons have exactly one observation period' AS VARCHAR(255))
 as achilles_heel_warning,
 43 as rule_id
from
 (
 select 100.0*achilles_results.count_value/ct.total_pts as one_obs_per_perc
  from @resultsDatabaseSchema.achilles_results
	join (select count_value as total_pts from @resultsDatabaseSchema.achilles_results r where analysis_id =1) as ct
	where analysis_id = 113 and stratum_1 = '1'
  ) d
where d.one_obs_per_perc >= 99.0;



--ruleid 44 DQ rule
--uses iris measure: patients with at least 1 Meas, 1 Dx and 1 Rx 


insert into @resultsDatabaseSchema.ACHILLES_HEEL_results (ACHILLES_HEEL_warning,rule_id)
SELECT 
  CAST('NOTIFICATION: Percentage of patients with at least 1 Measurement, 1 Dx and 1 Rx is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
  44 as rule_id
FROM @resultsDatabaseSchema.ACHILLES_results_derived d
where d.measure_id = 'ach_2002:Percentage'
and d.statistic_value < @ThresholdMinimalPtMeasDxRx  --threshold identified in the DataQuality study
;
