select domain_id as AttributeName, description as AttributeValue
from @cdm_database_schema.cdm_domain_meta
where description is not null
order by domain_id