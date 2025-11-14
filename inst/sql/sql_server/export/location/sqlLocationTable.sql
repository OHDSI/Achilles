WITH denom AS (
    SELECT 
        count_value 
    FROM 
        @results_database_schema.achilles_results 
    WHERE 
        analysis_id = 1
)
SELECT 
    c.analysis_id AS analysis_id,
    c.stratum_1 AS location_name,
    c.stratum_2 AS location_id,
    c.count_value AS count_persons,
    1.0 * c.count_value / denom.count_value AS percent_persons
FROM 
    @results_database_schema.achilles_results c,
    denom
WHERE 
    c.analysis_id BETWEEN 1100 AND 1103;