** Load the needed data
use "$carpetaMadre\\created_data\\data_for_voi.dta", clear


** Select the variables for calculating P' 
keep id2 cigs_x_day last_price income wtp_auction
sort id2

** Rescale the info to USD and drop missing values
replace last_price = last_price/3800
replace income = 12*income/3800
replace wtp_auction = wtp_auction/3800
replace cigs_x_day = cigs_x_day*30*12
drop if (cigs_x_day == . | last_price == . | income == .| wtp_auction == . )
drop if wtp_auction == 0 
export delimited "$carpetaMadre\\temp\\data_for_pp.csv", replace
** Handling no variations in wtp 
generate p_p = .
replace p_p = last_price if wtp_auction == 0
preserve 
keep if p_p != . 
save "$carpetaMadre\\temp\\wtp_delta_0.dta", replace
restore 
drop if p_p !=.
drop p_p

** Export them to a file
export delimited "$carpetaMadre\\temp\\data_for_pp.csv", replace