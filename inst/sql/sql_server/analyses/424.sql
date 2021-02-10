-- 424
-- For each condition concept, find and rank the top 10 co-occurring condition concepts.
--

-- HINT DISTRIBUTE_ON_KEY(stratum_1)
-- Find all condition_concept_id pairs, the number of people with these pairs, 
-- and the number of times these pairs occur.
with pairs as (
select c1.condition_concept_id condition_concept_id_1,
       c2.condition_concept_id condition_concept_id_2,
       count(distinct c2.person_id) num_people,
       count(*) num_cases
  from @cdmDatabaseSchema.condition_occurrence c1
  join @cdmDatabaseSchema.condition_occurrence c2
    on c1.person_id = c2.person_id
 where c1.condition_concept_id != 0
   and c2.condition_concept_id != 0
   and c1.condition_concept_id != c2.condition_concept_id
 group by c1.condition_concept_id, c2.condition_concept_id
), ranks as (
-- Rank order the pairs by the number of people who have them and use
-- the number of cases as a tie breaker
select condition_concept_id_1, 
       condition_concept_id_2, 
	   num_people,
	   num_cases,
       row_number()over(partition by condition_concept_id_1 order by num_people desc, num_cases desc) ranking
  from pairs
) 
select 424 as analysis_id,
       cast(condition_concept_id_1 as varchar(255)) as stratum_1,
	   cast(condition_concept_id_2 as varchar(255)) as stratum_2,
	   cast(ranking                as varchar(255)) as stratum_3,
	   cast(num_people             as varchar(255)) as stratum_4,
       cast(num_cases              as varchar(255)) as stratum_5,
	   num_people                  as count_value		
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_424 
  from ranks 
 where ranking <= 10
;
