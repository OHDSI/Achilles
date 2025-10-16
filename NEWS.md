# Achilles 1.8

## Improvements and New Features

- **Export Enhancements**
  - Added `unit_concept_id` to ARES export of measurement tables.
  - Improved unit concept ID naming and handling.
  - Added export of the location table to ARES.
  - Added database summary reporting.
  
- **Performance Improvements**
  - Refactored performance logs to be captured directly (not just through console logs).
  - Improved performance of ARES export, especially for DuckDB.
  - Optimized analyses for better performance, including analyses 117 and 1815.

- **Code Quality and Maintenance**
  - Fixed ambiguous `dplyr::select` statements and standardized column name casing (e.g., `IS_DEFAULT` → `is_default`).
  - Added missing SQL scripts for performance tracking.
  - Fixed fromJSON method usage for correctness.
  - Fixed errors when creating metadata tables with zero-length vectors.
  - Moved repeated subqueries to temp tables in some analyses.
  - Trimmed trailing whitespaces in export scripts.

- **Bug Fixes**
  - Fixed crash during `exportToAres` (DuckDB) related to unit concept IDs.
  - Handled missing server values in temporal characterization functions.

- **Documentation**
  - Updated and added links in the `DESCRIPTION` file.

## Notable Commits

- [Fix column name case: IS_DEFAULT → is_default](https://github.com/OHDSI/Achilles/commit/134bc0a7e0159dde85653ac41c1e73d8f4123fd1)
- [Ambiguous dplyr::select statements](https://github.com/OHDSI/Achilles/commit/889999c7a8b59476b8d4d95ee0d4d4a842db81ff)
- [Add db summary](https://github.com/OHDSI/Achilles/commit/87790da7453f0c8c2aa6d8e5071f5fa7a0a397fe)
- [Location table export to ARES](https://github.com/OHDSI/Achilles/commit/d5199716fca61bf4b45ab38ee8c1c441633743bc)
- [Improve performance of analysis 117](https://github.com/OHDSI/Achilles/commit/f9405e4a3b1a03ba4e4603db5774de96c5d8d3f6)
- [Add links to DESCRIPTION](https://github.com/OHDSI/Achilles/commit/c0f1a934c949a5b989f02eb56e271101306e1ed9)
- [Fix fromJSON correct method usage](https://github.com/OHDSI/Achilles/commit/b6ff65524a34da285e6340236791b00f6e32a39d)

---

For more, visit the [develop branch commit history](https://github.com/OHDSI/Achilles/commits?sha=develop&sort=updated).

# Achilles 1.7.2

1. Improved test setup management

# Achilles 1.7.1

Changes

1.  Bug fix for Oracle/SqlRender lack of support for 'As' with table alias.
2.  Improved consistency with version parameters.
3.  Adherence to HADES requirements.

# Achilles 1.7.0

Changes

Official 1.7 release: Comprehensive updates with over 200 issues closed over the 24 months.

With this release the main branch will now remain in sync with the latest release and ongoing development will be directed to the develop branch.
