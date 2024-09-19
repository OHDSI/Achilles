-- Analysis 2004: Number of distinct patients that overlap between specific domains
-- Bit String Breakdown:   1) Condition Occurrence 2) Drug Exposure 3) Device Exposure 4) Measurement 5) Death 6) Procedure Occurrence 7) Observation



select distinct person_id into #conoc from @cdmDatabaseSchema.condition_occurrence;
select distinct person_id into #drexp from @cdmDatabaseSchema.drug_exposure;
select distinct person_id into #dvexp from @cdmDatabaseSchema.device_exposure;
select distinct person_id into #msmt from @cdmDatabaseSchema.measurement;
select distinct person_id into #death from @cdmDatabaseSchema.death;
select distinct person_id into #prococ from @cdmDatabaseSchema.procedure_occurrence;
select distinct person_id into #obs from @cdmDatabaseSchema.observation;
select count(distinct(person_id)) as totalPersons into #totPers from @cdmDatabaseSchema.person;

create table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004 (
	analysis_id int, 
	stratum_1 varchar(255), 
	stratum_2 varchar(255), 
	stratum_3 varchar(255), 
	stratum_4 varchar(255), 
	stratum_5 varchar(255), 
	count_value int
);

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004 
select 2004 as analysis_id,
       CAST('0000001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from (
		select count(*) as count_value from (
			select person_id from #obs
			) subquery
		) personIntersection,
	(select totalPersons from #totPers) totalPersonsDb --  estimated cost >~ 1% of the complete query
; 

insert into #tmpach_2004 select 2004 as analysis_id,
       CAST('0000010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0000011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0000100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0000101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0000110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0000111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0001111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0010111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0011111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0100111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0101111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0110111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('0111111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1000111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1001111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1010111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1011111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1100111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1101111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1110111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111000' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111001' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111010' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111011' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111100' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111101' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111110' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) subquery) personIntersection,
  (select totalPersons from #totPers) totalPersonsDb
; 

insert into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004
select 2004 as analysis_id,
       CAST('1111111' AS VARCHAR(255)) as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) subquery) personIntersection,
  (select totalPersons from #totPers) as totalPersonsDb;
  

drop table #conoc;
drop table #drexp;
drop table #dvexp;
drop table #msmt;
drop table #death;
drop table #prococ;
drop table #obs;
drop table #totPers;