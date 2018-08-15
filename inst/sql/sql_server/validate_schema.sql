
with cte_care_site
as
(
select cast('care_site' as varchar(50)) as tablename
from (
  SELECT top 1
  care_site_id,
  location_id,
  place_of_service_concept_id,
  care_site_source_value,
  place_of_service_source_value
  FROM
  @cdmDatabaseSchema.care_site
) CARE_SITE
),
cte_cdm_source
as
(
  select cast('cdm_source' as varchar(50)) as tablename
  from (
  select top 1
  cdm_source_name,
  cdm_source_abbreviation,
  cdm_holder
  source_description,
  source_documentation_reference,
  cdm_etl_reference,
  source_release_date,
  cdm_release_date,
  cdm_version,
  vocabulary_version
  from 
  @cdmDatabaseSchema.cdm_source
) cdm_source
),
cte_cohort 
as
(
  select cast('cohort' as varchar(50)) as tablename
  from (
  SELECT top 1
  cohort_definition_id,
  subject_id,
  cohort_start_date,
  cohort_end_date
  FROM
  @resultsDatabaseSchema.cohort
) cohort
),
cte_condition_era
as
(
select cast('condition_era' as varchar(50)) as tablename
from (
  SELECT top 1
  condition_era_id,
  person_id,
  condition_concept_id,
  condition_era_start_date,
  condition_era_end_date,
  condition_occurrence_count
  FROM
  @cdmDatabaseSchema.condition_era
) CONDITION_ERA
),
cte_condition_occurrence
as
(
select cast('condition_occurrence' as varchar(50)) as tablename
from (
  SELECT top 1
  condition_occurrence_id,
  person_id,
  condition_concept_id,
  condition_start_date,
  condition_end_date,
  condition_type_concept_id,
  provider_id,
  visit_occurrence_id,
  condition_source_value,
  condition_source_concept_id
  FROM
  @cdmDatabaseSchema.condition_occurrence
) condition_occurrence
),
cte_death
as
(
select cast('death' as varchar(50)) as tablename
from (
  SELECT top 1
  person_id,
  death_date,
  death_type_concept_id,
  cause_concept_id,
  cause_source_value,
  cause_source_concept_id
  FROM
  @cdmDatabaseSchema.death
) death
),
cte_device_exposure
as
(
select cast('device_exposure' as varchar(50)) as tablename
from (
  SELECT top 1
  device_exposure_id, 
  person_id, 
  device_concept_id, 
  device_exposure_start_date, 
  device_exposure_end_date, 
  device_type_concept_id, 
  unique_device_id, 
  quantity, 
  provider_id, 
  visit_occurrence_id, 
  device_source_value, 
  device_source_concept_id
  FROM
  @cdmDatabaseSchema.device_exposure
) device_exposure
),
cte_dose_era
as
(
select cast('dose_era' as varchar(50)) as tablename
from (
  SELECT top 1
  dose_era_id, 
  person_id, 
  drug_concept_id, 
  unit_concept_id, 
  dose_value, 
  dose_era_start_date, 
  dose_era_end_date
  FROM
  @cdmDatabaseSchema.dose_era
) dose_era
),
cte_drug_era
as
(
select cast('drug_era' as varchar(50)) as tablename
from (
  SELECT top 1
  drug_era_id,
  person_id,
  drug_concept_id,
  drug_era_start_date,
  drug_era_end_date,
  drug_exposure_count
  FROM
  @cdmDatabaseSchema.drug_era
) drug_era
),
cte_drug_exposure
as
(
select cast('drug_exposure' as varchar(50)) as tablename
from (
  SELECT top 1
  {@cdmVersion=='5'}?{
  drug_exposure_id,
  person_id,
  drug_concept_id,
  drug_exposure_start_date,
  drug_exposure_end_date,
  drug_type_concept_id,
  stop_reason,
  refills,
  quantity,
  days_supply,
  sig,
  route_concept_id,
  effective_drug_dose,
  dose_unit_concept_id,
  lot_number,
  provider_id,
  visit_occurrence_id,
  drug_source_value,
  drug_source_concept_id,
  route_source_value,
  dose_unit_source_value
  }:{
    drug_exposure_id,
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    drug_exposure_start_datetime,
    drug_exposure_end_date,
    drug_exposure_end_datetime,
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    provider_id,
    visit_occurrence_id,
    {@cdmVersion == '5.3'}?{
      visit_detail_id,
    }
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
  }
  FROM
  @cdmDatabaseSchema.drug_exposure
) drug_exposure
),
cte_location
as
(
select cast('location' as varchar(50)) as tablename
from (
  SELECT top 1
  location_id,
  address_1,
  address_2,
  city,
  STATE,
  zip,
  county,
  location_source_value
  FROM
  @cdmDatabaseSchema.location
) location
),
{@cdmVersion == '5.3'}?{
  cte_metadata
  as
  (
    select cast('metadata' as varchar(50)) as tablename
    from (
      select top 1
      metadata_concept_id,
      metadata_type_concept_id,
      name,
      value_as_string,
      value_as_concept_id,
      metadata_date,
      metadata_datetime
      FROM
      @cdmDatabaseSchema.metadata
    ) metadata
  ),
}
cte_observation
as
(
select cast('observation' as varchar(50)) as tablename
from (
  SELECT top 1
  observation_id,
  person_id,
  observation_concept_id,
  observation_date,
  {@cdmVersion == '5.3'}?{
    observation_time,
  }
  value_as_number,
  value_as_string,
  value_as_concept_id,
  qualifier_concept_id,
  unit_concept_id,
  observation_type_concept_id,
  provider_id,
  visit_occurrence_id,
  observation_source_value,
  observation_source_concept_id,
  unit_source_value,
  qualifier_source_value
  FROM
  @cdmDatabaseSchema.observation
) observation
),
cte_observation_period
as
(
select cast('observation_period' as varchar(50)) as tablename
from (
  SELECT top 1
  observation_period_id,
  person_id,
  observation_period_start_date,
  observation_period_end_date
  FROM
  @cdmDatabaseSchema.observation_period
) observation_period
),
cte_payer_plan_period
as
(
select cast('payer_plan_period' as varchar(50)) as tablename
from (
  SELECT top 1
  payer_plan_period_id,
  person_id,
  payer_plan_period_start_date,
  payer_plan_period_end_date,
  payer_source_value,
  plan_source_value,
  family_source_value
  FROM
  @cdmDatabaseSchema.payer_plan_period
) payer_plan_period
),
cte_person
as
(
select cast('person' as varchar(50)) as tablename
from (
  SELECT top 1
  person_id,
  gender_concept_id,
  year_of_birth,
  month_of_birth,
  day_of_birth,
  race_concept_id,
  ethnicity_concept_id,
  location_id,
  provider_id,
  care_site_id,
  person_source_value,
  gender_source_value,
  race_source_value,
  ethnicity_source_value
  FROM
  @cdmDatabaseSchema.person
) person
),
cte_procedure_occurrence
as
(
select cast('procedure_occurrence' as varchar(50)) as tablename
from (
  SELECT top 1
  procedure_occurrence_id,
  person_id,
  procedure_concept_id,
  procedure_date,
  procedure_type_concept_id,
  modifier_concept_id,
  quantity,
  provider_id,
  visit_occurrence_id,
  procedure_source_value,
  procedure_source_concept_id,
  qualifier_source_value
  FROM
  @cdmDatabaseSchema.procedure_occurrence
) procedure_occurrence
),
cte_provider
as
(
select cast('provider' as varchar(50)) as tablename
from (
  SELECT top 1
  provider_id,
  NPI,
  DEA,
  specialty_concept_id,
  care_site_id,
  provider_source_value,
  specialty_source_value
  FROM
  @cdmDatabaseSchema.provider
) provider
),
cte_visit_occurrence
as
(
select cast('visit_occurrence' as varchar(50)) as tablename
from (
  SELECT top 1
  visit_occurrence_id,
  person_id,
  visit_start_date,
  visit_end_date,
  visit_type_concept_id,
  provider_id,
  care_site_id,
  visit_source_value,
  visit_source_concept_id
  FROM
  @cdmDatabaseSchema.visit_occurrence
) visit_occurrence
),
{@runCostAnalysis}?{
  {@cdmVersion == '5'}?{
    cte_drug_cost
    as
    (
      select cast('drug_cost' as varchar(50)) as tablename
      from (
        SELECT top 1
        drug_cost_id,
        drug_exposure_id,
        paid_copay,
        paid_coinsurance,
        paid_toward_deductible,
        paid_by_payer,
        paid_by_coordination_benefits,
        total_out_of_pocket,
        total_paid,
        ingredient_cost,
        dispensing_fee,
        average_wholesale_price,
        payer_plan_period_id
        FROM
        @cdmDatabaseSchema.drug_cost
      ) drug_cost
    ),
    cte_device_cost
    as
    (
      select cast('device_cost' as varchar(50)) as tablename
      from (
        select top 1
        device_cost_id,
        device_exposure_id,
        currency_concept_id,
        paid_copay,
        paid_coinsurance,
        paid_toward_deductible,
        paid_by_payer,
        paid_by_coordination_benefits,
        total_out_of_pocket,
        total_paid,
        payer_plan_period_id
        FROM
        @cdmDatabaseSchema.device_cost
      ) drug_cost
    ),
    cte_procedure_cost
    as
    (
      select cast('procedure_cost' as varchar(50)) as tablename
      from (
        SELECT top 1
        procedure_cost_id,
        procedure_occurrence_id,
        currency_concept_id,
        paid_copay,
        paid_coinsurance,
        paid_toward_deductible,
        paid_by_payer,
        paid_by_coordination_benefits,
        total_out_of_pocket,
        total_paid,
        revenue_code_concept_id,
        payer_plan_period_id,
        revenue_code_source_value
        FROM
        @cdmDatabaseSchema.procedure_cost
      ) procedure_cost
    ),
  }:{
    cte_cost
    as
    (
      select cast('cost' as varchar(50)) as tablename
      from (
        select top 1
        cost_id,
        cost_event_id,
        cost_domain_id,
        cost_type_concept_id,
        currency_concept_id,
        total_charge,
        total_cost,
        total_paid,
        paid_by_payer,
        paid_by_patient,
        paid_patient_copay,
        paid_patient_coinsurance,
        paid_patient_deductible,
        paid_by_primary,
        paid_ingredient_cost,
        paid_dispensing_fee,
        payer_plan_period_id,
        amount_allowed,
        revenue_code_concept_id,
        revenue_code_source_value
        FROM
        @cdmDatabaseSchema.cost
      ) cost
    ),
  }  
}
cte_all
as
(
  {@cdmVersion == '5.3'}?{
    select tablename from cte_metadata
    union all
  }
  select tablename from cte_care_site
  union all
  select tablename from cte_cdm_source
  union all
  select tablename from cte_condition_era
  union all
  select tablename from cte_condition_occurrence
  union all
  select tablename from cte_cohort
  union all
  select tablename from cte_death
  union all
  select tablename from cte_device_exposure
  union all
  select tablename from cte_dose_era
  union all
  select tablename from cte_drug_era
  union all
  select tablename from cte_drug_exposure
  union all
  select tablename from cte_location
  union all
  select tablename from cte_observation
  union all
  select tablename from cte_observation_period
  union all
  select tablename from cte_payer_plan_period
  union all
  select tablename from cte_person
  union all
  select tablename from cte_procedure_occurrence
  union all
  select tablename from cte_provider
  union all
  select tablename from cte_visit_occurrence
  {@runCostAnalysis}?{
    {@cdmVersion == '5'}?{
      union all
      select tablename from cte_drug_cost
      union all
      select tablename from cte_device_cost
      union all
      select tablename from cte_procedure_cost
    }:{
        union all
        select tablename from cte_cost
      }
  }
)
select tablename
from cte_all;
