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
###Simple rules: 
There are  simple rules that generate a single error or warning.

###Complex rules
However, some rules (e.g., rule_id 6) can generate multiple rows. The true primary key for output is combination of rule_id and analysis_id


#Possible outputs 
##Heel
All errors encoutered

##Full Data characterization
Full listing of AchillesResults and AchillesResultsDist tables

##Describe
We propose a new output table for Achilles that we refer to as AchillesDescribe 
This can be a subset of full output tables that removes some elements (e.g., frequency data that are sensitive to a data partner within a consortium/study).


```

#extensions to measures
621  (and similarly 421)

	
insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (621, 'Number of persons with at least one procedure occurrence, by procedure_concept_id by gender', 'procedure_concept_id', 'gender_concept_id');

	

--{621 IN (@list_of_analysis_ids)}?{
-- 621	Number of persons with at least one procedure occurrence, by procedure_concept_id by gender
-- why:existing analysis 604 by gender may double count distinc person_ids when same procedure repeats in two or more years 
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 621 as analysis_id,   
	po1.procedure_concept_id as stratum_1,
	p1.gender_concept_id as stratum_2,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.procedure_occurrence po1
on p1.person_id = po1.person_id
group by po1.procedure_concept_id, 
	p1.gender_concept_id
;
--}



 o<-read_csv(file='clipboard')
 o<-read.delim(file='clipboard')
 m<-left_join(filter(o,gender==8507) %>% select(proc,male=cnt),filter(o,gender==8532) %>% select(proc,female=cnt))
 
 m<-left_join(filter(o,gender==8507) %>% select(proc,male=cnt),
              filter(o,gender==8532) %>% select(proc,female=cnt))    %>%
    mutate(dif=male-female,ratio=male/female) %>% 
   filter(!is.na(ratio))
 
 # loadVocab <- function(){
 #   concept     <-read.delim('inst/extdata/concept.csv',as.is=T,quote = "")
 #   vocabulary  <-read.delim('inst/extdata/vocabulary.csv',as.is=T,quote = "")
 #   crel        <-read.delim('inst/extdata/concept_relationship.csv',as.is=T,quote = "")
 #   relationship<-read.delim('inst/extdata/relationship.csv',as.is=T,quote = "")
 #   cancestor   <-read.delim('inst/extdata/concept_ancestor.csv',as.is=T,quote = "")
 #   #vocabulary$VOCABULARY_ID
 #   library(dplyr)
 #   print(filter(vocabulary,VOCABULARY_ID=='None'))
 # }
 # 
 concept     <-read.delim('c:/w/w/rproject/cdmv/inst/extdata/concept.csv',as.is=T,quote = "")
 m2<-left_join(m,select(concept,proc=CONCEPT_ID,CONCEPT_NAME))
 
 
```



