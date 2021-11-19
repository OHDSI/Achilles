-- Analysis 2004: Number of distinct patients that overlap between specific domains
-- Bit String Breakdown:   1) Condition Occurrence 2) Drug Exposure 3) Device Exposure 4) Measurement 5) Death 6) Procedure Occurrence 7) Observation Period

select distinct person_id into #conoc from @cdmDatabaseSchema.condition_occurrence;
select distinct person_id into #drexp from @cdmDatabaseSchema.drug_exposure;
select distinct person_id into #dvexp from @cdmDatabaseSchema.device_exposure;
select distinct person_id into #msmt from @cdmDatabaseSchema.measurement;
select distinct person_id into #death from @cdmDatabaseSchema.death;
select distinct person_id into #prococ from @cdmDatabaseSchema.procedure_occurrence;
select distinct person_id into #obs from @cdmDatabaseSchema.observation_period;

with rawData as (
select 2004 as analysis_id,
       '0000001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0000010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0000011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0000100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0000101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0000110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0000111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0001111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0010111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0011111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0100111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0101111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0110111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '0111111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1000111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1001111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1010111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1011111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1100111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1101111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1110111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111000' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111001' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111010' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111011' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111100' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111101' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111110' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL
select 2004 as analysis_id,
       '1111111' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(6)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (select count(*) as count_value from(select person_id from #conoc intersect select person_id from #drexp intersect select person_id from #dvexp intersect select person_id from #msmt intersect select person_id from #death intersect select person_id from #prococ intersect select person_id from #obs) as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb) select * INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004 from rawData;
