  select c1.concept_id as ConceptId,  
    c1.concept_name as ConceptName,
  	num.stratum_2 as XCalendarMonth,   -- calendar year, note, there could be blanks
  	1000*(1.0*num.count_value/denom.count_value) as YPrevalence1000PP  --prevalence, per 1000 persons
  from 
  	(select * from ACHILLES_results where analysis_id = 402) num
  	inner join
  	(select * from ACHILLES_results where analysis_id = 117) denom
  	on num.stratum_2 = denom.stratum_1  --calendar year
  	inner join
  	@cdmSchema.dbo.concept c1
  	on CAST(num.stratum_1 AS INT) = c1.concept_id