SELECT
    l.@county_column AS county_id,
    l.@state_column AS state_id,
    lh.entity_id AS person_id,
    YEAR(lh.start_date) AS start_year,
    YEAR(lh.end_date) AS end_year
FROM
    @cdm_database_schema.location_history lh
    INNER JOIN @cdm_database_schema.location l
        ON l.location_id = lh.location_id
WHERE
    lh.domain_id = @person_domain_concept_id
    AND l.@state_column IS NOT NULL;
