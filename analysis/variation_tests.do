*===============================================================================
* tests for variation in extractions
* this file produces the results on variation in Section 3.2 of the manuscript
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/main_data_labels.dta"

xtset uniquesubject period 

levelsof self_type, local(endowment)
levelsof early, local(early)
forvalues i = 0/2 { // endowment
	di "-----------------------------------------------------------------------"
	di "endowment = " `i'
	forvalues j = 1/2 { // early
		di "	early = " `j'
		preserve
		quietly {
			keep if self_type == `i' & early == `j'
			mixed invest i.punishment || uniquegroup: || uniquesubject:, mle cluster(uniquegroup)
			predict r, residuals
			gen d = abs(r)
			xtreg d i.punishment, re 
		}
		di "	    Chi2 = " e(chi2) " "  "p-val = " e(p) " " "N = " e(N)
		di " "
		restore
	}
}
