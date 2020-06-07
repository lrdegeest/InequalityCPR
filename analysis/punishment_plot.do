*===============================================================================
* plot unconditional probablity and average punishment
* this file produces Figure 2 in the manuscript
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/targeting_data_labels.dta"

gen did_punish = cond(target_sanction > 0, 1, 0)

// P(punishment) by equal/unequal
graph bar (mean) did_punish, over(homo) blabel(total, format(%5.2f)) ///
	ylabel(, nogrid) ytitle("Frequency subjects" "engaged in punishment") ///
	name(p1, replace) nodraw

// P(punishment) by endowment	
graph bar (mean) did_punish, over(self_type) blabel(total, format(%5.2f)) ///
	ylabel(, nogrid) ytitle("Frequency subjects" "engaged in punishment") ///
	name(p2, replace) nodraw

// E[punishment | punishment > 0] by equal/unequal
graph bar (mean) target_sanction if target_sanction > 0, over(homo) ///
	ytitle("Average Punishment") ylabel(, nogrid) blabel(total, format(%5.2f)) ///
	ylabel(0(5)20, nogrid)  ///
	name(p3, replace) nodraw

// E[punishment | punishment > 0] by endowment
graph bar (mean) target_sanction if target_sanction > 0, over(self_type) ///
	ytitle("Average Punishment") ylabel(, nogrid) blabel(total, format(%5.2f)) ///
	ylabel(0(5)20, nogrid) ///
	name(p4, replace) nodraw

// combine the panels
gr combine p1 p2 p3 p4