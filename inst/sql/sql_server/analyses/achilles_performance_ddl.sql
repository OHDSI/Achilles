
-- DDL FOR THE ACHILLES_ANALYSIS TABLE

IF OBJECT_ID('@resultsDatabaseSchema.achilles_performance', 'U') IS NOT NULL
  DROP TABLE @resultsDatabaseSchema.achilles_performance;
  
CREATE TABLE @resultsDatabaseSchema.achilles_performance (
	analysis_id     INTEGER,
	elapsed_seconds   NUMERIC,
	start_time   NUMERIC,
	end_time  NUMERIC
);