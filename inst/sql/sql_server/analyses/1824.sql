-- 1824	
-- For each measurement concept, find and rank the top 10 co-occurring measurement concepts.
--

-- HINT DISTRIBUTE_ON_KEY(stratum_1)
-- Find all measurement_concept_id pairs, the number of people with these pairs, 
-- and the number of times these pairs occur.
with pairs as (
select m1.measurement_concept_id measurement_concept_id_1,
       m2.measurement_concept_id measurement_concept_id_2,
       count(distinct m2.person_id) num_people,
       count(*) num_cases
  from @cdmDatabaseSchema.measurement m1
  join @cdmDatabaseSchema.measurement m2
    on m1.person_id = m2.person_id
 where m1.measurement_concept_id != 0
   and m2.measurement_concept_id != 0
   and m1.measurement_concept_id != m2.measurement_concept_id
 group by m1.measurement_concept_id, m2.measurement_concept_id
), ranks as (
-- Rank order the pairs by the number of people who have them and use
-- the number of cases as a tie breaker
select measurement_concept_id_1, 
       measurement_concept_id_2, 
	   num_people,
	   num_cases,
       row_number()over(partition by measurement_concept_id_1 order by num_people desc, num_cases desc) ranking
  from pairs
) 
select 1824 as analysis_id,
       cast(measurement_concept_id_1 as varchar(255)) as stratum_1,
	   cast(measurement_concept_id_2 as varchar(255)) as stratum_2,
	   cast(ranking                  as varchar(255)) as stratum_3,
	   cast(num_people               as varchar(255)) as stratum_4,
       cast(num_cases                as varchar(255)) as stratum_5,
	   num_people                    as count_value		
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1824 
  from ranks 
 where ranking <= 10
;
