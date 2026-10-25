-- locations summarised to the finest region level; only used for names and display centroids
SELECT
    l.@county_column AS county_id,
    l.@state_column AS state_id,
    MAX(l.county) AS county_name,
    AVG(l.latitude) AS latitude,
    AVG(l.longitude) AS longitude,
    COUNT_BIG(*) AS n_locations
FROM
    @cdm_database_schema.location l
WHERE
    l.@state_column IS NOT NULL
GROUP BY
    l.@county_column,
    l.@state_column;
