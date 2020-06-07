*===============================================================================
* plot the variation in extractions over time
* this file produces Figure 1 in the manuscript
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/main_data_labels.dta"

preserve
levelsof early, local(time)
levelsof punishment, local(pun)
levelsof self_type, local(endowment)
// 1. estimate the kernel densities
// creates 3 endowments * 2 punishment treatments * 2 time indicators = 12 variables
// e.g. dens011 means "density for early + no punishment + equal"
// dens[early or late][no pun or pun][endowment]
quietly {
	foreach i in `time' {
		foreach j in `pun' {
			foreach k in `endowment' {
				capture drop x`i'`j'`k' dens`i'`j'`k'
				kdensity invest if self_type == `k' &  punishment == `j' & early == `i', generate(x`i'`j'`k' dens`i'`j'`k') nodraw
				qui summarize invest if self_type == `k' &  punishment == `j' & early == `i'
				replace x`i'`j'`k' = r(max) if x`i'`j'`k' > r(max)
				replace x`i'`j'`k' = 0 if x`i'`j'`k' < 0
			}
		}
	}
}
// 2. plot
// each plot is a combination of early OR late + endowment + no punishment AND punishment
// i.e. p[early or late][endowment]
// e.g. p10 is plot for early + equal
gen zero_base = 0
levelsof early, local(time)
levelsof self_type, local(endowment)
foreach i in `time' {
	foreach k in `endowment' {
		local subtitle	: label (self_type)	`k'
			twoway	(rarea dens`i'0`k' zero_base x`i'0`k', color("blue%50")) /// no punishment
					(rarea dens`i'1`k' zero_base x`i'1`k', color("orange%50")), /// punishment
					ytitle("Smoothed density") xtitle("Extraction") ///
					subtitle("`subtitle'") ///
					xlabel(0(10)60) ///
					legend(order(1 "No Punishment" 2 "Punishment") cols(2)) ///
					name(p`i'`k', replace) nodraw
	}
}
restore

// combine the figures
grc1leg p10 p11 p12, cols(3) legendfrom(p10) subtitle("Early (Periods 1-7)") name(combo1, replace) 
grc1leg p20 p21 p22, cols(3) legendfrom(p20) subtitle("Late (Periods 8-15)") name(combo2, replace)  
grc1leg combo1 combo2, legendfrom(combo1) cols(1) // this is Figure 1