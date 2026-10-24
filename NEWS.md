# Achilles (development)

1. New optional `exportGeoToAres()` creates aggregated geographic exposure files (from `external_exposure`, `location` and `location_history`) for the ARES Geographic Exposures report. `exportToAres()` runs it automatically when the data is present (`exportGeo = "auto"`) and skips it silently otherwise.

# Achilles 1.7.1

Changes

1.  Bug fix for Oracle/SqlRender lack of support for 'As' with table alias.
2.  Improved consistency with version parameters.
3.  Adherence to HADES requirements.

# Achilles 1.7.0

Changes

Official 1.7 release: Comprehensive updates with over 200 issues closed over the 24 months.

With this release the main branch will now remain in sync with the latest release and ongoing development will be directed to the develop branch.
