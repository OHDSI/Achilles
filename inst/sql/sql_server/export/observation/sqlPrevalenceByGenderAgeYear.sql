select c1.concept_id as CONCEPT_ID,  --all rows for all concepts, but you may split by conceptid
	c1.concept_name as CONCEPT_NAME,
	cast(cast(num.stratum_4 as int)*10 as varchar) + '-' + cast((cast(num.stratum_4 as int)+1)*10-1 as varchar) as TRELLIS_NAME, --age decile
	c2.concept_name as SERIES_NAME,  --gender
	num.stratum_2 as X_CALENDAR_YEAR,   -- calendar year, note, there could be blanks
	round(1000*(1.0*num.count_value/denom.count_value),5) as Y_PREVALENCE_1000PP  --prevalence, per 1000 persons
from 
	(select * from ACHILLES_results where analysis_id = 804) num
	inner join
	(select * from ACHILLES_results where analysis_id = 116) denom on num.stratum_2 = denom.stratum_1  --calendar year
		and num.stratum_3 = denom.stratum_2 --gender
		and num.stratum_4 = denom.stratum_3 --age decile
	inner join @cdmSchema.dbo.concept c1 on num.stratum_1 = CAST(c1.concept_id as VARCHAR)
	inner join @cdmSchema.dbo.concept c2 on num.stratum_3 = CAST(c2.concept_id as VARCHAR)
where c2.concept_id in (8507, 8532)
ORDER BY c1.concept_id, CAST(num.stratum_2 as INT)
