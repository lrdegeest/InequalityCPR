*===============================================================================
* tests and counts of punishment
* this file produces the test results and counts in Section 3.3 of the manuscript
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/targeting_data_labels.dta"

*===============================================================================
* TREATMENT EFFECTS
// test of P(punish)
qui xtprobit did_punish i.homo, vce(cluster uniquegroup)
test 1.homo

// same but between low and high
qui xtprobit did_punish i.self_type if homo==0, vce(cluster uniquegroup)
test 2.self_type

// test of punishment size
preserve
collapse (mean) target_sanction if target_sanction > 0, by(homo uniquegroup)
ranksum target_sanction, by(homo)
restore

// same but between low and high
preserve
collapse (mean) target_sanction if target_sanction > 0 & homo == 0, by(self_type uniquegroup)
ranksum target_sanction, by(self_type)
restore
*===============================================================================

*===============================================================================
*COUNTS

// Unequal: overall
count if homo == 0 & target_sanction > 0
local c1 = r(N)
count if homo == 0
local c2 = r(N)
di `c1'/`c2'

// Unequal: < 40
count if homo == 0 & target_invest <= 40 & target_sanction > 0
local c1 = r(N)
count if homo == 0 & target_invest <= 40 
local c2 = r(N)
di `c1'/`c2'

// Unequal: < 25
count if homo == 0 & target_invest <= 25 & target_sanction > 0
local c1 = r(N)
count if homo == 0 & target_invest <= 25 
local c2 = r(N)
di `c1'/`c2'


// High: >40
qui count if homo == 0 & target_invest > 40 & target_sanction > 0
local c1 = r(N)
qui count if homo == 0 & target_invest > 40
local c2 = r(N)
di `c1'/`c2'


// Equal: < 40
count if homo == 1 & target_invest <= 40 & target_sanction > 0
local c1 = r(N)
count if homo == 1 & target_invest <= 40 
local c2 = r(N)
di `c1'/`c2'


// Equal: overall
count if homo == 1 & target_sanction > 0
local c1 = r(N)
count if homo == 1
local c2 = r(N)
di `c1'/`c2'
*===============================================================================