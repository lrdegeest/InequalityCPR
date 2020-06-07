*===============================================================================
* summary tables: Earnings (Table 2 in the manuscript) and Extractions (Table 3) 
* author: @lrdegeest
*===============================================================================

version 15
clear

// data
use "../data/main_data_labels.dta"

preserve
// calculate averages by group and early
collapse (mean) invest=invest profit=profit, by(homo self_type punishment early uniquegroup)
*=========OVERALL equal/unequal
// average invest 
table homo punishment, c(mean invest sd invest n invest) format(%9.2f)
// average profit
table homo punishment, c(mean profit sd profit n profit) format(%9.2f)
*=========early/late equal/unequal
// average invest
table homo punishment early, c(mean invest sd invest n invest) format(%9.2f)
// average profit
table homo punishment early, c(mean profit sd profit n profit) format(%9.2f)

*=========OVERALL endowments
// average invest 
table self_type punishment, c(mean invest sd invest n invest) format(%9.2f)
// average profit
table self_type punishment, c(mean profit sd profit n profit) format(%9.2f)
*=========early/late endowments
// average invest
table self_type punishment early, c(mean invest sd invest n invest) format(%9.2f)
// average profit
table self_type punishment early, c(mean profit sd profit n profit) format(%9.2f)
restore