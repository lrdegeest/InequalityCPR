*===============================================================================
* labeling and cleaning the main data set
* each row is a subject i in period t
* this file produces main_data_labels.dta
* author: @lrdegeest
*===============================================================================

clear 
insheet using "data.csv"

// insheet adds a bunch of empty rows (why?); delete them
gen case_id = _n
drop if case_id > 2048

// labeling
label define endowments 0 "Unequal" 1 "Equal"
label values homo endowments 
label define pun 0 "No Punishment" 1 "Punishment"
label values ff pun
gen self_type = 0 if token == 50
replace self_type = 1 if token == 40
replace self_type = 2 if token == 60
label define self_type 0 "Equal" 1 "Low" 2 "High"
label values self_type self_type 

// drop practice round
drop if roundid == 1
gen period = roundid - 1
gen early = cond(period < 8, 1, 2)
label define early 1 "Early" 2 "Late"
label values early early

// gen profit variable
gen profit = total2 if ff == 1
replace profit = total if ff == 0

// gen unique group indicator
gen uniquegroup = 100*homo + 10*session + gameid

// renaming
rename ff punishment
rename ProfileID uniquesubject

// save
save "main_data_labels.dta", replace
