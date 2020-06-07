*===============================================================================
* tests on extractions and earnings
* this file produces signrank and ranksum tests in Sections 3.2 and 3.3 of the manuscript
* author: @lrdegeest and David Kingsley
*===============================================================================

version 15
clear

//data
use "../data/main_data_labels.dta"

*===============================================================================
* EXTRACTIONS ranksum tests

* ALL PERIODS ======================================
preserve
collapse (mean) invest, by(punishment uniquegroup homo)
* EQUAL 
ranksum 	invest	if homo == 1, by(punishment)
* UNEQUAL 
ranksum 	invest	if homo == 0, by(punishment)
restore

* EARLY/LATE ======================================
preserve
collapse (mean) invest, by(punishment uniquegroup homo early)
* EQUAL (Footnote 15)
ranksum 	invest	if homo == 1 & early == 1, by(punishment)
ranksum 	invest	if homo == 1 & early == 2, by(punishment)
* UNEQUAL (Footnote 15)
ranksum 	invest	if homo == 0 & early == 1, by(punishment)
ranksum 	invest	if homo == 0 & early == 2, by(punishment)
restore

* BY TYPE ======================================
preserve
collapse (mean) invest, by(punishment uniquegroup self_type)
table punishment self_type, c(mean invest sd invest n invest)

* UNEQUAL 
ttest	 	invest	if self_type == 1, by(punishment)
ranksum 	invest	if self_type == 1, by(punishment)
ranksum 	invest	if self_type == 2, by(punishment)
restore

* EARLY/LATE
preserve
collapse (mean) invest, by(punishment uniquegroup self_type early)
table punishment self_type early, c(mean invest sd invest n invest)

* UNEQUAL (Footnote 16)
ranksum 	invest	if self_type == 1 & early == 1, by(punishment)
ranksum 	invest	if self_type == 1 & early == 2, by(punishment)
ranksum 	invest	if self_type == 2 & early == 1, by(punishment)
ranksum 	invest	if self_type == 2 & early == 2, by(punishment)
restore
*===============================================================================

*===============================================================================
* EARNINGS rank sum tests

* ALL PERIODS ======================================
preserve
collapse (mean) profit, by(public punishment uniquegroup homo)
* EQUAL (footnote 11)
ranksum 	profit	if homo == 1 & public == 0, by(punishment)
* UNEQUAL (footnote 12)
ranksum 	profit	if homo == 0 & public == 0, by(punishment)
* PUN (footnote 10)
ranksum 	profit	if punishment == 1 & public == 0, by(homo)
* No PUN (footnote 9)
ranksum 	profit	if punishment == 0 & public == 0, by(homo)
restore

* EARLY/LATE ======================================
preserve
collapse (mean) profit, by(punishment uniquegroup homo early)
* EQUAL (footnote 11)
ranksum 	profit	if homo == 1 & early == 1, by(punishment)
ranksum 	profit	if homo == 1 & early == 2, by(punishment)
* UNEQUAL (footnote 12)
ranksum 	profit	if homo == 0 & early == 1, by(punishment)
ranksum 	profit	if homo == 0 & early == 2, by(punishment)
* PUN (footnote 10)
ranksum 	profit	if punishment == 1 & early == 1, by(homo)
ranksum 	profit	if punishment == 1 & early == 2, by(homo)
* No PUN (footnote 9)
ranksum 	profit	if punishment == 0 & early == 1, by(homo)
ranksum 	profit	if punishment == 0 & early == 2, by(homo)
restore

* BY TYPE ======================================
preserve
collapse (mean) profit, by(punishment uniquegroup self_type)
* UNEQUAL (footnote 13 and 14)
ranksum 	profit	if self_type == 1, by(punishment)
ranksum 	profit	if self_type == 2, by(punishment)
restore

* BY TYPE & EARLY/LATE ======================================
preserve
collapse (mean) profit, by(punishment uniquegroup self_type early)
* UNEQUAL (footnote 13 and 14)
ranksum 	profit	if self_type == 1 & early == 1, by(punishment)
ranksum 	profit	if self_type == 1 & early == 2, by(punishment)
ranksum 	profit	if self_type == 2 & early == 1, by(punishment)
ranksum 	profit	if self_type == 2 & early == 2, by(punishment)
restore
*===============================================================================

*===============================================================================
* SIGNRANK tests of average group extractions and theoretical benchmarks

* ALL PERIODS ======================================
preserve
collapse (mean) invest, by(punishment self_type uniquegroup homo)
* EQUAL
signrank invest = 25 if homo == 1 & punishment == 0
signrank invest = 25 if homo == 1 & punishment == 1
* UNEQUAL, LOW
signrank invest = 29 if self_type == 1 & punishment == 0
signrank invest = 29 if self_type == 1 & punishment == 1 
signrank invest = 25 if self_type == 1 & punishment == 0
signrank invest = 25 if self_type == 1 & punishment == 1 
* UNEQUAL, HIGH
signrank invest = 29 if self_type == 2 & punishment == 0
signrank invest = 29 if self_type == 2 & punishment == 1
signrank invest = 25 if self_type == 2 & punishment == 0
signrank invest = 25 if self_type == 2 & punishment == 1
restore

* EARLY/LATE ======================================
preserve
collapse (mean) invest, by(punishment self_type uniquegroup homo early)
* EQUAL
signrank invest = 25 if homo == 1 & punishment == 0 & early == 1
signrank invest = 25 if homo == 1 & punishment == 0 & early == 2
signrank invest = 25 if homo == 1 & punishment == 1 & early == 1
signrank invest = 25 if homo == 1 & punishment == 1 & early == 2

* UNEQUAL, LOW
signrank invest = 29 if self_type == 1 & punishment == 0 & early == 1
signrank invest = 29 if self_type == 1 & punishment == 0 & early == 2
signrank invest = 29 if self_type == 1 & punishment == 1 & early == 1
signrank invest = 29 if self_type == 1 & punishment == 1 & early == 2

* UNEQUAL, HIGH
signrank invest = 29 if self_type == 2 & punishment == 0 & early == 1
signrank invest = 29 if self_type == 2 & punishment == 0 & early == 2
signrank invest = 29 if self_type == 2 & punishment == 1 & early == 1
signrank invest = 29 if self_type == 2 & punishment == 1 & early == 2
restore
*===============================================================================