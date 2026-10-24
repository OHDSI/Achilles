-- one row per person x region x exposure concept x calendar year (year of exposure_start_date)
SELECT
    ee.exposure_concept_id AS exposure_concept_id,
    l.@county_column AS county_id,
    l.@state_column AS state_id,
    YEAR(ee.exposure_start_date) AS period,
    ee.person_id AS person_id,
    COUNT_BIG(*) AS n_records,
    AVG(ee.value_as_number) AS value_mean
FROM
    @cdm_database_schema.external_exposure ee
    INNER JOIN @cdm_database_schema.location l
        ON l.location_id = ee.location_id
WHERE
    ee.value_as_number IS NOT NULL
    AND l.@state_column IS NOT NULL
GROUP BY
    ee.exposure_concept_id,
    l.@county_column,
    l.@state_column,
    YEAR(ee.exposure_start_date),
    ee.person_id;
