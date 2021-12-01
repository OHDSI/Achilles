Achilles
========

[![Build Status](https://travis-ci.org/OHDSI/Achilles.svg?branch=master)](https://travis-ci.org/OHDSI/Achilles)
[![codecov.io](https://codecov.io/github/OHDSI/Achilles/coverage.svg?branch=master)](https://codecov.io/github/OHDSI/Achilles?branch=master)

Introduction
============
**A**utomated **C**haracterization of **H**ealth **I**nformation at **L**arge-scale **L**ongitudinal **E**vidence **S**ystems (ACHILLES)---descriptive statistics and data quality checks on an OMOP CDM databases.  ACHILLES currently supports CDM version 5.3 and 5.4.

* Vignette: [Running Achilles on Your CDM](https://github.com/OHDSI/Achilles/raw/master/vignettes/RunningAchilles.pdf)

Features
========
- Performs broad database characterization
- Export feature for AchillesWeb 

Technology
==========
Achilles is an R package.

System Requirements
============
Requires R (version 3.6.0 or higher). 

Installation
=============
1. See the instructions [here](https://ohdsi.github.io/Hades/rSetup.html) for configuring your R environment, including RTools and Java.

2. In R, use the following commands to download and install Achilles:

  ```r
  install.packages("devtools")
  devtools::install_github("OHDSI/Achilles")
  ```

User Documentation
==================
Documentation can be found on the [package website](https://ohdsi.github.io/Achilles).

PDF versions of the documentation are also available:
* Vignette: [Running Achilles](https://raw.githubusercontent.com/OHDSI/Achilles/master/inst/doc/RunningAchilles.pdf)
* Package manual: [Achilles.pdf](https://raw.githubusercontent.com/OHDSI/Achilles/master/extras/Achilles.pdf)

Support
=======
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forums</a>
* We use the <a href="https://github.com/OHDSI/Achilles/issues">GitHub issue tracker</a> for all bugs/issues/enhancements

Contributing
============
Read [here](https://ohdsi.github.io/Hades/contribute.html) how you can contribute to this package.

License
=======
Achilles is licensed under Apache License 2.0

Development
===========
Achilles is being developed in R Studio.

Development status
==================
Achilles is ready for use.

#### Acknowledgements
- This project is supported in part through the National Science Foundation grant IIS 1251151.
