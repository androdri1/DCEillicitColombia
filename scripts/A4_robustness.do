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


preserve 

**** beta survey timing *************************************
	* Preliminaries 
	gen timMin=interviewtime/60
	drop if timMin<5 | timMin>60
	
	* Design a 
		* Run the regression - non smokers 
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & smoker == 0), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_no_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_no_smok
			
		* Run the regression - smokers
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & smoker == 1), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
					(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_smok
			
	* Design b
		* Run the regression - non smokers 
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & smoker == 0, ///
			group(c_id) vce(cluster id2) 
		estimates store beta_ill_no_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_no_smok
			
		* Run the regression - smokers
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & smoker == 1, ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_ill_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_smok
			
	* Creating the tables 
	etable, ///
		estimates(wtp_no_ill_no_smok wtp_no_ill_smok wtp_ill_no_smok wtp_ill_smok) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A10_panel_a.docx", replace)
		
	etable, ///
			estimates(beta_no_ill_no_smok beta_no_ill_smok beta_ill_no_smok beta_ill_smok) /////
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit coefficients") ///
		export("$carpetaMadre\\temp\\beta_res_survey_time.docx", replace)
restore 


preserve 
**** beta no dominated responses *************************************
	* Preliminaries 
	gen AlgunDomx = (dominated==1 | dominated==2 | dominated==3) & choice==1
	bys id2: egen AlgunDom=max(AlgunDomx)
	keep if AlgunDom==0
	
	* Design a 
		* Run the regression - non smokers 
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & smoker == 0), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_no_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_no_smok
			
		* Run the regression - smokers
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & smoker == 1), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
					(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_smok
			
	* Design b
		* Run the regression - non smokers 
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & smoker == 0, ///
			group(c_id) vce(cluster id2) 
		estimates store beta_ill_no_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_no_smok
			
		* Run the regression - smokers
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & smoker == 1, ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_ill_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_smok
			
	* Creating the tables 
	etable, ///
		estimates(wtp_no_ill_no_smok wtp_no_ill_smok wtp_ill_no_smok wtp_ill_smok) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A10_panel_b.docx", replace)
		
	etable, ///
		estimates(beta_no_ill_no_smok beta_no_ill_smok beta_ill_no_smok beta_ill_smok) /////
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit coefficients") ///
		export("$carpetaMadre\\temp\\beta_res_non_dominated.docx", replace)
restore 

preserve
**** beta dropping the 7th 
	* Preliminaries 
	drop if cset == 7
	
	* Design a 
		* Run the regression - non smokers 
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & smoker == 0), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_no_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_no_smok
			
		* Run the regression - smokers
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block == 3 & smoker == 1), ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_no_ill_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
					(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_smok
			
	* Design b
		* Run the regression - non smokers 
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & smoker == 0, ///
			group(c_id) vce(cluster id2) 
		estimates store beta_ill_no_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_no_smok
			
		* Run the regression - smokers
		clogit choice priceusd Nonbranded_pack warn_stick illegal none if ///
			(block==1 | block==2) & smoker == 1, ///
			group(c_id) vce(cluster id2) 	
		estimates store beta_ill_smok

		* Compute the wtp 
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_smok
			
	* Creating the tables 
	etable, ///
		estimates(wtp_no_ill_no_smok wtp_no_ill_smok wtp_ill_no_smok wtp_ill_smok) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A10_panel_c.docx", replace)
		

	etable, ///
		estimates(beta_no_ill_no_smok beta_no_ill_smok beta_ill_no_smok beta_ill_smok) /////
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		title("C-logit coefficients") ///
		export("$carpetaMadre\\temp\\beta_res_wo_7th.docx", replace)
restore 