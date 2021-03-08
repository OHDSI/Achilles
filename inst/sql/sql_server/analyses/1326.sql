-- 1326	Number of records by domain by visit detail concept id

SELECT 
	1326 AS analysis_id,
	CAST(v.visit_detail_concept_id AS VARCHAR(255)) AS stratum_1,
	v.cdm_table AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	v.record_count AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1326
FROM (
	SELECT 'drug_exposure' cdm_table,
		COALESCE(vd.visit_detail_concept_id, 0) visit_detail_concept_id,
		COUNT(*) record_count
	FROM 
		@cdmDatabaseSchema.drug_exposure de
	LEFT JOIN 
		@cdmDatabaseSchema.visit_detail vd 
	ON 
		de.visit_occurrence_id = vd.visit_occurrence_id
	GROUP BY 
		vd.visit_detail_concept_id
	
	UNION
	
	SELECT 
		'condition_occurrence' cdm_table,
		COALESCE(vd.visit_detail_concept_id, 0) visit_detail_concept_id,
		COUNT(*) record_count
	FROM 
		@cdmDatabaseSchema.condition_occurrence co
	LEFT JOIN 
		@cdmDatabaseSchema.visit_detail vd 
	ON 
		co.visit_occurrence_id = vd.visit_occurrence_id
	GROUP BY 
		vd.visit_detail_concept_id

	UNION

	SELECT 
		'device_exposure' cdm_table,
		COALESCE(visit_detail_concept_id, 0) visit_detail_concept_id,
		COUNT(*) record_count
	FROM 
		@cdmDatabaseSchema.device_exposure de
	LEFT JOIN 
		@cdmDatabaseSchema.visit_detail vd 
	ON 
		de.visit_occurrence_id = vd.visit_occurrence_id
	GROUP BY 
		vd.visit_detail_concept_id

	UNION

	SELECT 
		'procedure_occurrence' cdm_table,
		COALESCE(vd.visit_detail_concept_id, 0) visit_detail_concept_id,
		COUNT(*) record_count
	FROM 
		@cdmDatabaseSchema.procedure_occurrence po
	LEFT JOIN 
		@cdmDatabaseSchema.visit_detail vd 
	ON 
		po.visit_occurrence_id = vd.visit_occurrence_id
	GROUP BY 
		vd.visit_detail_concept_id

	UNION

	SELECT 
		'measurement' cdm_table,
		COALESCE(vd.visit_detail_concept_id, 0) visit_detail_concept_id,
		COUNT(*) record_count
	FROM 
		@cdmDatabaseSchema.measurement m
	LEFT JOIN 
		@cdmDatabaseSchema.visit_detail vd 
	ON 
		m.visit_occurrence_id = vd.visit_occurrence_id
	GROUP BY 
		vd.visit_detail_concept_id

	UNION

	SELECT 
		'observation' cdm_table,
		COALESCE(vd.visit_detail_concept_id, 0) visit_detail_concept_id,
		COUNT(*) record_count
	FROM 
		@cdmDatabaseSchema.observation o
	LEFT JOIN 
		@cdmDatabaseSchema.visit_detail vd 
	ON 
		o.visit_occurrence_id = vd.visit_occurrence_id
	GROUP BY 
		vd.visit_detail_concept_id

	) v;
