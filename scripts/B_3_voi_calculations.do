* Paths definition
if "`c(username)'"=="juanm" {
	glo carpetaMadre="C:\Users\juanm\OneDrive - Universidad del rosario\Documentos - Control Tabaco Facultad Economica\DCE\paper_files\read_me_folder"
}


** Load the p_prime data and append it with the file with no wtp variations
import delimited "$carpetaMadre\\raw_data\\p_prime_res.csv", clear
destring p_prime, force replace
drop if p_prime == . 
rename p_prime p_p

append using "$carpetaMadre\\temp\\wtp_delta_0.dta"

*** Setting up the parameters for the calculations
generate elasprix = -0.66
generate elasrevenu = 0.33
order id2 last_price p_p elasprix elasrevenu income cigs_x_day wtp_auction

* local alpha = -0.44 // Price elasticity
* local delta = 0.33 // income elasticity

*** Perform the calculations as in the Excel file sent by the authors
generate cv = wtp_auction*cigs_x_day
generate ah = cigs_x_day/((last_price^elasprix)*(income^elasrevenu))
generate Vv22 = ((-ah*last_price^(1+elasprix)/(1+elasprix))+(income^(1-elasrevenu))/(1-elasrevenu))
generate y_cv = income - cv
generate int1 = (1+elasprix)*(y_cv^(-elasrevenu))* ///
				(y_cv-Vv22*(y_cv^(elasrevenu))+elasrevenu*Vv22*(y_cv^(elasrevenu)))  
generate int2 = -int1/(ah*(-1+elasrevenu))
generate int3 = int2^(1/(1+elasprix))
generate s = last_price - int3
generate z = Vv22+ah*((p_p-s)^(1+elasprix))/(1+elasprix)
generate z1 = ((1-elasrevenu)*z)^(1/(1-elasrevenu))
generate a = Vv22 + ah*((last_price-s)^(1+elasprix))/(1+elasprix)
generate a1 = ((1-elasrevenu)*a)^(1/(1-elasrevenu))
generate effetprix = -(z1-a1)
generate autre = (last_price-p_p)*cigs_x_day
generate Total = autre - effetprix
sum Total

drop if Total == . 

** Merge with the file with characteristics and keep the needed observations
merge 1:1 id2 using "$carpetaMadre\\created_data\\data_for_voi.dta"
keep if _merge == 3
drop _merge
** keep id2 Total smoker internal_group age block 
tab smoker
tabstat Total, by (block) stat(mean sd N)

** Write the file for the VOI tables
save "$carpetaMadre\\created_data\\data_for_voi_tables.dta", replace