*===============================================================================
* label and clean the targeting data set
* each row is a subject i in period t targeting subject j \neq i
* this file produces targeting_data_labels.data
* author: @lrdegeest
*===============================================================================

version 15
clear 

// load the data produced by targeting_data_cleaning.R
use "../data/targeting_data.dta"

// labeling
label define endowments 0 "Unequal" 1 "Equal"
label values homo endowments 
gen self_type = 3 if token == 50
replace self_type = 1 if token == 40
replace self_type = 2 if token == 60
label define self_type 3 "Equal" 1 "Low" 2 "High"
label values self_type self_type
gen target_type = 3 if target_endow == 50
replace target_type = 1 if target_endow == 40
replace target_type = 2 if target_endow == 60
label values target_type self_type

// reset periods so they start at 1
gen period = roundid - 1

// rename groupid
rename gameid uniquegroup

// rename unique subject
rename profileid uniquesubject

// mean contribution by group and period
egen mean_invest = mean(invest), by(uniquegroup period)

// unequal: revealing endowments
gen reveal_type = 1 if homo == 0 & target_invest > 40
replace reveal_type = 0 if homo == 0 & reveal_type == .

// save
save "../data/targeting_data_labels.dta", replace