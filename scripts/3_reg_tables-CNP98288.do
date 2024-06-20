*******************************************************************************
* Load the data for the regressions
if "`c(username)'"=="paul.rodriguez" {
	glo carpetaMadre="D:\Paul.Rodriguez\Universidad del rosario\Control Tabaco Facultad Economica - Documentos\DCE\paper_files\read_me_folder"
}

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

gen young = age>=26 & age<.
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

* Assign labels to the variables for Table requested by referee 
generate design_type = D1
label define d_type 0 "Design A (Only licit alternatives)" ///
					1 "Design B (Licit & illicit alternatives)"
label values design_type d_type

**# Power calculations matrix  **********************************************
** Isolate the required variables and export a .csv file with this data
preserve 
keep block id2 c_id smoker cset alt choice choice priceusd Nonbranded_pack warn_stick illegal none
order block id2 c_id smoker cset alt choice choice priceusd Nonbranded_pack warn_stick illegal none
*export delimited "$carpetaMadre\\temp\\power_mat.csv", replace
restore 

**# Chosen packages frequencies *********************************************
** Compute the total of observations per design and smoker types 
preserve 
collapse (sum) total = choice, by(design_type smoker)
tempfile total_design_smoker
save `total_design_smoker'
restore

** Compute the total of observations per design, smoker and package types 
preserve
collapse (sum) choice, by(design_type smoker pack_type_id)
merge m:1 design_type smoker using `total_design_smoker', nogen
generate freq = choice/total

** Partially set up the table
keep design_type smoker pack_type_id freq
order design_type smoker pack_type_id freq
export excel "$carpetaMadre\\temp\\table_3_frequencies.xlsx", replace
restore

**# Main Results #1 ************************************************************

glo refPrice=2
glo refPrice1=3

* MNL model on choices  ........................................................
	*Tobacco; we expect price, branded_pack to be positive... as they are
	* warn_stick and illegal to be negative... the first, only if illegal cigs are not
	* presented; and the second is actually positive!!

	** Block 3 (Design 2/A ) - No ilicit
	* Non-smokers only 
		* Run the model
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block==3 & smoker==0), group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_no_ill_wo_smok
		
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice} )"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `None')"
		
		disp `None'/`denom' // Prob for "none"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom'), post 
		}
		
		estimates store pr_no_ill_wo_smok
	
		* Compute marginal effects and store them
		estimates restore betas_no_ill_wo_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') /// * Dissuasive stick 
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom'), post
		estimates store no_ill_wo_smok
		
		* Compute WTP 
		estimates restore betas_no_ill_wo_smok
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_wo_smok
		
	* Smokers only
		* Run the model
		clogit choice priceusd Nonbranded_pack warn_stick none if ///
			(block==3 & smoker==1), group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_no_ill_w_smok
		
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice} )"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom'), post 
		}
		estimates store pr_no_ill_w_smok

		* Compute marginal effects and store them
		estimates restore betas_no_ill_w_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') ///
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom'), post
		estimates store no_ill_w_smok
		
		* Compute WTP 
		estimates restore betas_no_ill_w_smok
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]), post
		estimates store wtp_no_ill_w_smok

		
		* ......................................................................
		* Exercise none and cessation ... (en vez de none, se pone branded_pack como referencia)
			gen otraref = warn_stick==0 & branded_pack==1
			clogit choice priceusd Nonbranded_pack warn_stick otraref if ///
			(block==3 & smoker==0), group(c_id) vce(cluster id2) 		
				
			* Computations with the coefficients
			local brandedNostick "exp( _b[otraref] )"
			local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
			local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
			local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
			local None           " _b[priceusd]*${refPrice} "
			local NoneP1         " _b[priceusd]*${refPrice1} "
			local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `None')"		
				
			nlcom (marginPrice: (`NoneP1'-`None')/`denom' ) (baseNone: (`None')/`denom')  (elast: ( (`NoneP1'-`None')/`denom' )*2 /(`None'/`denom') ) 
				
		
** Blocks 1 and 2 (Design 1/B )
	* Non-smokers only
		* Run the model
		clogit choice priceusd Nonbranded_pack warn_stick illegal none ///
			if (block==1 | block==2) & smoker==0, group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_ill_wo_smok
			
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice})"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local illicit	"exp( _b[illegal]+ _b[priceusd]*${refPrice})"
		local illicitP1 "exp( _b[illegal]+ _b[priceusd]*${refPrice1})"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `illicit' +`None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom'), post 
		}

		estimates store pr_ill_wo_smok
		
		* Compute marginal effects and store them * Illicit vs branded no stick
		estimates restore betas_ill_wo_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') ///
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom') ///
			(marginIllicit: (`illicit'-`brandedNostick')/`denom'), post 
		estimates store ill_wo_smok
		
		* Compute WTP 
		estimates restore betas_ill_wo_smok
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_wo_smok
	
	* Smokers only
		* Run the model
		clogit choice priceusd Nonbranded_pack warn_stick illegal none ///
			if (block==1 | block==2) & smoker==1, group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_ill_w_smok
		
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice} )"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local illicit	"exp( _b[illegal]+ _b[priceusd]*${refPrice} )"
		local illicitP1 "exp( _b[illegal]+ _b[priceusd]*${refPrice1} )"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `illicit' +`None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom'), post 
		}
		
		estimates store pr_ill_w_smok
	
		* Compute marginal effects and store them
		estimates restore betas_ill_w_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') ///
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom') ///
			(marginIllicit: (`illicit'-`brandedNostick')/`denom'), post 
		estimates store ill_w_smok
		
		* Compute WTP 
		estimates restore betas_ill_w_smok
		nlcom (nonBranded: -_b[Nonbranded_pack]/_b[priceusd]) ///
			(dissStick: -_b[warn_stick]/_b[priceusd]) ///
			(illicit: -_b[illegal]/_b[priceusd]), post
		estimates store wtp_ill_w_smok
		
** Estimations tables building before minor edits 
	
	* Marginal effects - Table 3 panel A values ** Statistics should be taken from table A4
	etable, ///
		estimates(no_ill_wo_smok no_ill_w_smok ill_wo_smok ill_w_smok) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit marginal effects") ///
		keep(marginPrice marginPlain marginStickBran marginStickPlain marginIllicit) ///
		export("$carpetaMadre\\created_data\\tables_main\\table_3_panel_a.docx", replace)
		
	* Willingness-to-pay - Table 3 panel B 
	etable, ///
		estimates(wtp_no_ill_wo_smok wtp_no_ill_w_smok wtp_ill_wo_smok wtp_ill_w_smok) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit willigness-to-pay") ///
		export("$carpetaMadre\\created_data\\tables_main\\table_3_panel_b.docx", replace)
	
	* Betas - Table A4 of the appendix ** Statistics should be moved to Table 3 of the main
	etable, ///
		estimates(betas_no_ill_wo_smok betas_no_ill_w_smok betas_ill_wo_smok betas_ill_w_smok) ///
		column(index) showstars showstarsnote title("C-logit coefficients") ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A4_panel_a.docx", replace)
				
	* Probabilities - Table A4 of the appendix 
	etable, ///
		estimates(pr_no_ill_wo_smok pr_no_ill_w_smok pr_ill_wo_smok pr_ill_w_smok) ///
		column(index) showstars showstarsnote title("C-logit probabilities") ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A4_panel_b.docx", replace)
	
	xx
		

* MNL model on risk  ........................................................
** Block 3 (Design 2/A ) - No ilicit
	* Non-smokers only 
		* Run the model
		clogit safe priceusd Nonbranded_pack warn_stick none if ///
			(block==3 & smoker==0), group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_no_ill_wo_smok
		
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice} )"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom'), post 
		}
		
		estimates store pr_no_ill_wo_smok
	
		* Compute marginal effects and store them
		estimates restore betas_no_ill_wo_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') /// * Dissuasive stick 
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom'), post
		estimates store no_ill_wo_smok
		
	* Smokers only
		* Run the model
		clogit safe priceusd Nonbranded_pack warn_stick none if ///
			(block==3 & smoker==1), group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_no_ill_w_smok
		
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice} )"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom'), post 
		}
		estimates store pr_no_ill_w_smok

		* Compute marginal effects and store them
		estimates restore betas_no_ill_w_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') ///
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom'), post
		estimates store no_ill_w_smok

** Blocks 1 and 2 (Design 1/B )
	* Non-smokers only
		* Run the model
		clogit safe priceusd Nonbranded_pack warn_stick illegal none ///
			if (block==1 | block==2) & smoker==0, group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_ill_wo_smok
			
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice})"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local illicit	"exp( _b[illegal]+ _b[priceusd]*${refPrice})"
		local illicitP1 "exp( _b[illegal]+ _b[priceusd]*${refPrice1})"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `illicit' +`None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom'), post 
		}

		estimates store pr_ill_wo_smok
		
		* Compute marginal effects and store them * Illicit vs branded no stick
		estimates restore betas_ill_wo_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') ///
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom') ///
			(marginIllicit: (`illicit'-`brandedNostick')/`denom'), post 
		estimates store ill_wo_smok
	
	* Smokers only
		* Run the model
		clogit safe priceusd Nonbranded_pack warn_stick illegal none ///
			if (block==1 | block==2) & smoker==1, group(c_id) vce(cluster id2) 	
		
		* Store the estimated coefficients 
		estimates store betas_ill_w_smok
		
		* Computations with the coefficients
		local brandedNostick "exp( _b[priceusd]*${refPrice} )"
		local brandedNostickP1 "exp( _b[priceusd]*${refPrice1} )"
		local brandedStick   "exp( _b[warn_stick] +_b[priceusd]*${refPrice} )"
		local plainNostick   "exp( _b[Nonbranded_pack]+ _b[priceusd]*${refPrice} )"
		local plainStick     "exp( _b[Nonbranded_pack]+ _b[warn_stick] + _b[priceusd]*${refPrice} )"
		local illicit	"exp( _b[illegal]+ _b[priceusd]*${refPrice} )"
		local illicitP1 "exp( _b[illegal]+ _b[priceusd]*${refPrice1} )"
		local None           "exp(_b[none])"
		local denom "(`brandedNostick' + `plainNostick' + `brandedStick' + `plainStick' + `illicit' +`None')"
		
		*Compute probabilities and store them 
		capture{
		nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom') ///
			 (pr_None: (`None')/`denom'), post 
		}
		if _rc != 0{
			nlcom (pr_brandedNostick: (`brandedNostick')/`denom') ///
			(pr_plainNostick: (`plainNostick')/`denom') ///
			(pr_brandedStick: (`brandedStick')/`denom') ///
			(pr_plainStick: (`plainStick')/`denom') ///
			(pr_illicit: (`illicit')/`denom'), post 
		}
		
		estimates store pr_ill_w_smok
	
		* Compute marginal effects and store them
		estimates restore betas_ill_w_smok
		nlcom (marginPrice: (`brandedNostickP1'-`brandedNostick')/`denom') ///
			(marginPlain: (`plainNostick'-`brandedNostick')/`denom') ///
			(marginStickBran: (`brandedStick'-`brandedNostick')/`denom') ///
			(marginStickPlain: (`plainStick'-`plainNostick')/`denom') ///
			(marginIllicit: (`illicit'-`brandedNostick')/`denom'), post 
		estimates store ill_w_smok
		
** Estimations tables building
	* Marginal effects - Table 4 of the paper
	etable, ///
		estimates(no_ill_wo_smok no_ill_w_smok ill_wo_smok ill_w_smok) ///
		column(index) showstars showstarsnote ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		title("C-logit marginal effects") ///
		keep(marginPrice marginPlain marginStickBran marginStickPlain marginIllicit) ///
		export("$carpetaMadre\\created_data\\tables_main\\table_4.docx", replace)

	* Betas - Table A5 of the appendix 
	etable, ///
		estimates(betas_no_ill_wo_smok betas_no_ill_w_smok betas_ill_wo_smok betas_ill_w_smok) ///
		column(index) showstars showstarsnote title("C-logit coefficients") ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
		mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
		mstat(aic, nformat(%8.0fc) label("AIC")) ///
		mstat(bic, nformat(%8.0fc) label("BIC")) ///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A5_panel_a.docx", replace)
				
	* Probabilities 
	etable, ///
		estimates(pr_no_ill_wo_smok pr_no_ill_w_smok pr_ill_wo_smok pr_ill_w_smok) ///
		column(index) showstars showstarsnote title("C-logit probabilities") ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N_clust, nformat(%8.0fc) label("Respondents")) 
		///
		export("$carpetaMadre\\created_data\\tables_appendix_A\\table_A5_panel_b.docx", replace)