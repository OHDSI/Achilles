
-- DDL FOR THE ACHILLES_ANALYSIS TABLE

IF OBJECT_ID('@resultsDatabaseSchema.achilles_analysis', 'U') IS NOT NULL
  DROP TABLE @resultsDatabaseSchema.achilles_analysis;
  
CREATE TABLE @resultsDatabaseSchema.achilles_analysis (
	analysis_id     INTEGER,
	analysis_name   VARCHAR(255),
	stratum_1_name  VARCHAR(255),
	stratum_2_name  VARCHAR(255),
	stratum_3_name  VARCHAR(255),
	stratum_4_name  VARCHAR(255),
	stratum_5_name  VARCHAR(255),
	is_default      INTEGER,
	category        VARCHAR(255)
);

