-- 503 Death type distribution by cause concept id

select 503 as analysis_id,
    CAST(d.cause_concept_id AS VARCHAR(255)) as stratum_1,
    CAST(d.death_type_concept_id AS VARCHAR(255)) as stratum_2,
    cast(null as varchar(255)) as stratum_3,
    cast(null as varchar(255)) as stratum_4,
    cast(null as varchar(255)) as stratum_5,
    COUNT_BIG(d.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_503
from @cdmDatabaseSchema.death d
join @cdmDatabaseSchema.observation_period op
    on d.person_id = op.person_id
    and d.death_date >= op.observation_period_start_date
    and d.death_date <= op.observation_period_end_date
where d.cause_concept_id IS NOT NULL
    AND d.cause_concept_id != 0
group by d.cause_concept_id, d.death_type_concept_id
;