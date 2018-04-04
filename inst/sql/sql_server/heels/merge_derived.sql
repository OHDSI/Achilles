IF OBJECT_ID('@schema@schemaDelim@destination', 'U') IS NOT NULL 
  DROP TABLE @schema@schemaDelim@destination;

select 
  analysis_id, 
	stratum_1,
	stratum_2,
	statistic_value,
	measure_id
into @schema@schemaDelim@destination
from
(
  @derivedSqls
) Q
;