  select c1.concept_id as ConceptId,  
    c1.concept_name as ConceptName,
  	cast(cast(num.stratum_4 as int)*10 as varchar) + '-' + cast((cast(num.stratum_4 as int)+1)*10-1 as varchar) as TrellisName, --age decile
  	c2.concept_name as SeriesName,  --gender
  	num.stratum_2 as XCalendarYear,   -- calendar year, note, there could be blanks
  	1000*(1.0*num.count_value/denom.count_value) as YPrevalence1000PP  --prevalence, per 1000 persons
  from 
  	(select * from ACHILLES_results where analysis_id = 404) num
  	inner join
  	(select * from ACHILLES_results where analysis_id = 116) denom
  	on num.stratum_2 = denom.stratum_1  --calendar year
  	and num.stratum_3 = denom.stratum_2 --gender
  	and num.stratum_4 = denom.stratum_3 --age decile
  	inner join
  	concept c1
  	on num.stratum_1 = c1.concept_id
  	inner join
  	concept c2
  	on num.stratum_3 = c2.concept_id