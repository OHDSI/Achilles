SELECT
    ee.exposure_concept_id AS exposure_concept_id,
    ee.unit_concept_id AS unit_concept_id,
    COUNT_BIG(*) AS n_records
FROM
    @cdm_database_schema.external_exposure ee
WHERE
    ee.value_as_number IS NOT NULL
GROUP BY
    ee.exposure_concept_id,
    ee.unit_concept_id;
