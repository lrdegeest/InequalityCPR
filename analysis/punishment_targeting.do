*===============================================================================
* targeting and expected punishment
* this file produces Figure 3 and Table A1 in the manuscript
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/targeting_data_labels.dta"

*===============================================================================
// expected punishment for each extraction
capture program drop expectedcost
program expectedcost, eclass
	version 15
	syntax [if]
	tempname em im b ec
	qui xtset uniquesubject
	preserve
	qui keep `if'
	qui levelsof target_type, local(t)
	local num : word count `t'
	if homo == 1 { // equal endowments
		local endow 50
		local start 0
		local m 3
	}
	else if homo == 0 & `num' == 2 { // unequal endowments, low and high
		qui keep if target_invest <= 40
		local endow 40
		local start 0
		local m 1
	}
	else if homo == 0 & target_type == 2 { // just high
		qui keep if target_invest > 40
		local endow 60
		local start 45 
		local m 2
	}
	local controls target_invest invest mean_invest lagsanctioncost period
	// P(SANCTION)
	di "Extensive Margin..."
	qui eststo em`m': xtprobit target_sanction `controls', vce(cluster uniquegroup)
	qui margins, at(target_invest = (`start'(5)`endow')) post
	matrix `em' = e(b)
	// save the average marginal effects
	qui estimates restore em`m'
	qui eststo em_ame_`m': margins, dydx(*) post
	// E(SANCTION | SANCTION > 0)
	di "Intensive Margin..."
	qui eststo im`m': xtpoisson target_sanction `controls' if target_sanction > 0, vce(cluster uniquegroup)
	qui margins, at(target_invest = (`start'(5)`endow')) predict(xb) post
	matrix `b' = e(b)
	mata : st_matrix("`im'", exp(st_matrix("`b'")))
	// save the average marginal effects
	qui estimates restore im`m'
	qui eststo im_ame_`m': margins, dydx(*) post
	// P(SANCTION) * E(SANCTION | SANCTION > 0)
	local dim `= colsof(`em')'
	matrix `ec' = J(1,`dim',0)
	local N 3
	di "Expected Cost..."
	forvalues i = 1/`dim' {
		matrix `ec'[1,`i'] = `N' * (`em'[1,`i'] * `im'[1,`i'])
	}
	ereturn post `ec'
	restore
	di "Done"
end

// equal endowments
expectedcost if homo == 1
mat ec_equal = e(b)'
mat empty_equal = (.,.)'
mat ec_equal2 = (ec_equal \ empty_equal)

// unequal endowments, extractions = [0,40]
expectedcost if homo == 0
mat ec_unequal = e(b)'
mat empty_unequal = (.,.,.,.)'
mat ec_unequal2 = (ec_unequal \ empty_unequal)

// unequal endowments, high extractions = [45,60]
expectedcost if homo == 0 & target_type == 2
mat ec_high = e(b)'
mat ec_high2 = (ec_unequal \ ec_high)

// combine
mat x = (0,5,10,15,20,25,30,35,40,45,50,55,60)'
mat expected_cost = x, ec_equal2, ec_unequal2, ec_high2
mat colnames expected_cost = extract equal unequal high

// average marginal effects table (Table A1)
esttab em_ame_3 em_ame_1 em_ame_2 im_ame_3 im_ame_1 im_ame_2 using targeting_ame.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_p, fmt(0) labels("N")) ///
	numbers nodepvars booktabs collabels(none) ///
	label legend ///
	mtitles("Equal" "Unequal" "High" "Equal" "Unequal" "High") ///
	mgroups("Extensive margin" "Intensive margin", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	varlabels(_cons Constant period Period mean_invest "Average Extraction" ///
	target_invest "Target Extraction" invest "Own Extraction" ///
	lagsanctioncost "Lagged Sanctions Received" ) 

	
// plot (Figure 3)
clear
svmat expected_cost, names(col)
tw	(connected equal extract) ///
	(connected unequal extract) ///
	(connected high extract if extract > 40, msymbol(T) lpattern(dash)) ///
	(line high extract, lpattern(dash)), ///
	xlabel(0(10)60) ///
	ytitle("Expected punishment (EDs)") xtitle("Extraction") ///
	legend(order(1 "Equal" 2 "Unequal (Low + High)" 3 "High") ring(0) pos(11))
*===============================================================================
