-- 824
-- For each observation concept, find and rank the top 10 co-occurring observation concepts.
--

-- HINT DISTRIBUTE_ON_KEY(stratum_1)
-- Find all observation_concept_id pairs, the number of people with these pairs, 
-- and the number of times these pairs occur.
with pairs as (
select o1.observation_concept_id observation_concept_id_1,
       o2.observation_concept_id observation_concept_id_2,
       count(distinct o2.person_id) num_people,
       count(*) num_cases
  from @cdmDatabaseSchema.observation o1
  join @cdmDatabaseSchema.observation o2
    on o1.person_id = o2.person_id
 where o1.observation_concept_id != 0
   and o2.observation_concept_id != 0
   and o1.observation_concept_id != o2.observation_concept_id
 group by o1.observation_concept_id, o2.observation_concept_id
), ranks as (
-- Rank order the pairs by the number of people who have them and use
-- the number of cases as a tie breaker
select observation_concept_id_1, 
       observation_concept_id_2, 
	   num_people,
	   num_cases,
       row_number()over(partition by observation_concept_id_1 order by num_people desc, num_cases desc) ranking
  from pairs
) 
select 824 as analysis_id,
       cast(observation_concept_id_1 as varchar(255)) as stratum_1,
	   cast(observation_concept_id_2 as varchar(255)) as stratum_2,
	   cast(ranking                  as varchar(255)) as stratum_3,
	   cast(num_people               as varchar(255)) as stratum_4,
       cast(num_cases                as varchar(255)) as stratum_5,
	   num_people                    as count_value		
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_824 
  from ranks 
 where ranking <= 10
;
