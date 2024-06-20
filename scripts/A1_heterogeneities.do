*******************************************************************************
* Load the data for the regressions
use "$carpetaMadre\\created_data\\data_for_regs.dta", clear

* Label the variables for generating the regressions
label variable priceDM "Price Legal"
label variable priceCG "Price Illicit"
label var priceusd "Price" //<<<<<<<

label variable branded_pack "Branded pack"
label variable warn_stick "Warning stick"
label variable illegal "Illicit"
label variable none "None"

gen Nonbranded_pack= 1-branded_pack
label variable Nonbranded_pack "Plain package"

gen D1 = 1- D2
gen pDMxD1     = priceusd*D1
gen NonbrandedxD1 = Nonbranded_pack*D1
gen warningxD1 = warn_stick*D1
gen nonexD1    = none*D1

label variable D1 "Design 1"
label variable pDMxD1 "P. Legal x Design 1"
label variable NonbrandedxD1 "Plain package x Design 1"
label variable warningxD1 "Warning x Design 1"
label variable nonexD1    "None x Design 1"

gen young = age<=26 & age<.
gen pDMxY        = priceusd*young
gen NonbrandedxY = Nonbranded_pack*young
gen warningxY    = warn_stick*young
gen illegalxY    = illegal*young
gen nonexY       = none*young


label var young "Young"
label variable pDMxY "P. Legal x Young"
label variable NonbrandedxY "Plain package x Young"
label variable warningxY "Warning x Young"
label variable illegalxY "Illicit x Young"
label variable nonexY    "None x Young"

glo priceDM = 2.4 // 9000/3800
glo priceCG = 1   // 4000/3800


* Merge with the descriptives data for keeping some neede variables
	merge m:1 id2 using ///
		"$carpetaMadre\created_data\data_for_descriptive_stats.dta", nogen
	
	* Drop non smokers
	drop if smoker != 1
	generate heavy_smoker = (cigs_x_day>11)

**** WTP results young and adult smokers ***************************
	* Design a 
		* Run the regression - Young people
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & young == 1), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_young

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_young
			
		* Run the regression - adults
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & young == 0), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_adult

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
					(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_adult 
			
	* Design b
		* Run the regression - Young people
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & young == 1, ///
			group(c_id) vce(cluster id2) 
		estimates store beta_ill_young

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_young
			
		* Run the regression - adults
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & young == 0, ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_ill_adult

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_adult
			
	* Creating the tables 
	etable, ///
		estimates(wtp_no_ill_young wtp_no_ill_adult wtp_ill_young wtp_ill_adult) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A6_panel_a.docx", replace)
		
	etable, ///
		estimates(beta_no_ill_young beta_no_ill_adult beta_ill_young beta_ill_adult) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit coefficients") ///
		export("$carpetaMadre\\temp\\beta_res_age.docx", replace)
		
		
**** WTP results income level ***************************

	* Design a 
		* Run the regression - low income
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & lowinc == 1), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_low

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_low
			
		* Run the regression - high income
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & lowinc == 0), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_high

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
					(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_high 
			
	* Design b
		* Run the regression - low income 
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & lowinc == 1, ///
			group(c_id) vce(cluster id2) 
		estimates store beta_ill_low

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_low
			
		* Run the regression - high income 
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & lowinc == 0, ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_ill_high

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_high
			
	* Creating the tables 
	etable, ///
		estimates(wtp_no_ill_low wtp_no_ill_high wtp_ill_low wtp_ill_high) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\table_A6_panel_b.docx", replace)
		
	etable, ///
		estimates(beta_no_ill_low beta_no_ill_high beta_ill_low beta_ill_high) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit coefficients") ///
		export("$carpetaMadre\\temp\\beta_res_income.docx", replace)
		
**** WTP results consumption patterns ***************************

	* Design a 
		* Run the regression - light smokers 
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & heavy_smoker == 0), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_light

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_light
			
		* Run the regression - adults
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & heavy_smoker == 1), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_heavy

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
					(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_heavy 
			
	* Design b
		* Run the regression - Young people
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & heavy_smoker == 0, ///
			group(c_id) vce(cluster id2) 
		estimates store beta_ill_light

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_light
			
		* Run the regression - adults
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & heavy_smoker == 1, ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_ill_heavy

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_heavy
			
	* Creating the tables 
	etable, ///
		estimates(wtp_no_ill_light wtp_no_ill_heavy wtp_ill_light wtp_ill_heavy) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\table_A6_panel_c.docx", replace)
		
	etable, ///
		estimates(beta_no_ill_light beta_no_ill_heavy beta_ill_light beta_ill_heavy) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit coefficients") ///
		export("$carpetaMadre\\temp\\beta_res_patterns.docx", replace)