These notes relate Achilles and Achilles Heel to Data Quality Model (DQM)

DQM terminology is slightly different

**Achilles term = DQM term**  
analysis = measure  
stratum = dimension  
rule = check




#Types of analyses

##By outputed results
###Stratified analyses

use table ACHILLES_results

###distributions 
use table ACHILLES_results_dist
e.g., 103,104,105,106,107,203,206,211,403,406,506,511,512,513,514,515,603,606,704,706,715,716,717,803,806,815

##By nature

###general
Some analyses are checking data size (and useful in general)  
###conformance to data model
Other analyses have only while others are s
###data quality specific analyses
e.g., analysis_id 7,8,9,207





#Analyzing Heel Results
###Simple rules: There are  simple rules that generate a single error or warning

###Complex rules: However, some rules (e.g., rule_id 6) can generate multiple rows. The true primary key for output is combination of rule_id and analysis_id


