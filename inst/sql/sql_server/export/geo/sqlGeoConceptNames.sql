SELECT
    c.concept_id AS concept_id,
    c.concept_name AS concept_name
FROM
    @vocab_database_schema.concept c
WHERE
    c.concept_id IN (@concept_ids);
