-- 624
-- For each procedure concept, find and rank the top 10 co-occurring procedure concepts.
--

-- HINT DISTRIBUTE_ON_KEY(stratum_1)
-- Find all procedure_concept_id pairs, the number of people with these pairs, 
-- and the number of times these pairs occur.
with pairs as (
select p1.procedure_concept_id procedure_concept_id_1,
       p2.procedure_concept_id procedure_concept_id_2,
       count(distinct p2.person_id) num_people,
       count(*) num_cases
  from @cdmDatabaseSchema.procedure_occurrence p1
  join @cdmDatabaseSchema.procedure_occurrence p2
    on p1.person_id = p2.person_id
 where p1.procedure_concept_id != 0
   and p2.procedure_concept_id != 0
   and p1.procedure_concept_id != p2.procedure_concept_id
 group by p1.procedure_concept_id, p2.procedure_concept_id
), ranks as (
-- Rank order the pairs by the number of people who have them and use
-- the number of cases as a tie breaker
select procedure_concept_id_1, 
       procedure_concept_id_2, 
	   num_people,
	   num_cases,
       row_number()over(partition by procedure_concept_id_1 order by num_people desc, num_cases desc) ranking
  from pairs
) 
select 624 as analysis_id,
       cast(procedure_concept_id_1 as varchar(255)) as stratum_1,
	   cast(procedure_concept_id_2 as varchar(255)) as stratum_2,
	   cast(ranking                as varchar(255)) as stratum_3,
	   cast(num_people             as varchar(255)) as stratum_4,
       cast(num_cases              as varchar(255)) as stratum_5,
	   num_people                  as count_value		
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_624 
  from ranks 
 where ranking <= 10
;
