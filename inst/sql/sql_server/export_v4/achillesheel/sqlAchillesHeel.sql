select analysis_id as AttributeName, @results_database_schema.ACHILLES_HEEL_warning as AttributeValue
from @results_database_schema.ACHILLES_HEEL_results
order by case when left(@results_database_schema.ACHILLES_HEEL_warning,5) = 'Error' then 1 else 2 end, analysis_id