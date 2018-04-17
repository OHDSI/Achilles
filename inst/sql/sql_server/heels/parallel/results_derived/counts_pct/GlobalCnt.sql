--general derived measures
--non-CDM sources may generate derived measures directly
--for CDM and Achilles: the fastest way to compute derived measures is to use
--existing measures
--derived measures have IDs over 100 000 (not any more, instead, they use measure_id as their id)


--event type derived measures analysis xx05 is often analysis by xx_type
--generate counts for meas type, drug type, proc type, obs type
--optional TODO: possibly rewrite this with CASE statement to better make 705 into drug, 605 into proc ...etc
--               in measure_id column (or make that separate sql calls for each category)


select analysis_id, stratum_1, stratum_2, sum(count_value) as statistic_value, measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  --100000+analysis_id, 
  select
    NULL as analysis_id,
    stratum_2 as stratum_1,
    null as stratum_2,
    count_value,
    CAST(concat('ach_',CAST(analysis_id as VARCHAR), ':GlobalCnt') as varchar(255)) as measure_id
  from @resultsDatabaseSchema.ACHILLES_results 
  where analysis_id in (1805,705,605,805,405) 
) Q
group by analysis_id, stratum_1, stratum_2, measure_id
;
