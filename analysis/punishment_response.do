*===============================================================================
* response to punishment
* this file produces Table 4 in the manuscript
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/main_data_labels.dta"

keep if punishment == 1 // keep the punishment treatments
egen mean_invest = mean(invest), by(uniquegroup period) // average extraction by group and period
gen dev = mean_invest - invest // deviatiation in t; dev < 0 means they extracted above group average
xtset uniquesubject period // set the panel
gen lag_invest = l.invest // lag extraction
gen delta_invest = invest - lag_invest // change in extraction
gen lag_received  = l.received // lag sanctions received

// estimate model for extractions below average
qui eststo m1_endow: xtreg delta_invest dev i.self_type#c.lag_received if dev > 0, re cluster(uniquegroup)
qui eststo m1_homo: xtreg delta_invest dev i.homo#c.lag_received if dev > 0, re cluster(uniquegroup)
qui test 0.homo#c.lag_received = 1.homo#c.lag_received 
estadd scalar test_stat=r(chi2): m1_homo
estadd scalar test_pvalue=r(p): m1_homo

// estimate model for extractions above average
qui eststo m2_endow: xtreg delta_invest dev i.self_type#c.lag_received if dev < 0, re cluster(uniquegroup)
qui eststo m2_homo: xtreg delta_invest dev i.homo#c.lag_received if dev < 0, re cluster(uniquegroup)
qui test 0.homo#c.lag_received = 1.homo#c.lag_received 
estadd scalar test_stat=r(chi2): m2_homo
estadd scalar test_pvalue=r(p): m2_homo

// reg table
esttab m1_homo m1_endow m2_homo m2_endow using delta_harvest.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N test_stat test_pvalue, fmt(0 2 2) labels("N " "\chi^2-test for treatment differences")) ///
	label legend ///
	numbers nodepvars nomtitles booktabs collabels(none) ///
	mgroups("Extractions below average" "Extractions above average", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	varlabels(	_cons Constant ///
				dev "Deviation in t" ///
				1.homo#c.lag_received "Punishment in t X Equal" ///
				0.homo#c.lag_received "Punishment in t X Unequal" ///
				0.self_type#c.lag_received "Punishment in t X Equal" ///
				1.self_type#c.lag_received "Punishment in t X Low" ///
				2.self_type#c.lag_received "Punishment in t X High" ///
				) 