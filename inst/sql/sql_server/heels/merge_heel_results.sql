IF OBJECT_ID('@schema@schemaDelim@destination', 'U') IS NOT NULL 
  DROP TABLE @schema@schemaDelim@destination;

select 
  analysis_id,
	achilles_heel_warning,
	rule_id,
	record_count
into @schema@schemaDelim@destination
from
(
  @resultSqls
) Q
;