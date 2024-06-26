***===================================
/* Tried running the iterations for finding the betas and WTP's without bootstrapping unsuccesfully
*/


** Setting up the directory for writing the needed tables
global carpetaMadre = "C:\Users\juanm\OneDrive - Universidad del rosario\Documentos - Control Tabaco Facultad Economica\DCE\paper_files\read_me_folder"

** Load the data for the latent class model
use "$carpetaMadre\\created_data\\data_for_regs.dta", clear

** Merge with the descriptive stats data 
merge m:1 id2 using ///
	"$carpetaMadre\created_data\data_for_descriptive_stats.dta", nogen

** Preliminaries 
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
	
	save "$carpetaMadre\\temp\\db_for_lclogit_w_demog.dta", replace
	
	* Define the membership variables 
	local mem_vars age male high_school technical college lowinc highinc 
	
************************************************************+
* Iterate across outcomes
local dep_var choice

* Define the table that will be written
if "`dep_var'" == "choice"{
	local table = "A8"
}
else{
	local table = "A9"
}

* Iterate across designs and smoking status
local design A
local smoker ns
preserve

* Select the sample depending on the characteristics
if "`design'" == "A"{
	keep if design_type == 0
	local tab_design = "a"
}
else{
	keep if design_type == 1	
	local tab_design  = "b"
}

if "`smoker'" == "s"{
	keep if smoker == 1
}
else{
	keep if smoker == 0 
}

	** a. Run the conditional logit model with latent classes
	lclogit2 `dep_var', rand(priceusd Nonbranded_pack warn_stick illegal ///
	none) id(id2) group(c_id) nclasses(2) seed(1) nolog ///
	ltolerance(0.001) membership(`mem_vars')
	matrix start = e(b)
		
	** b. Run the MLL with starting values for computing SE's
	lclogitml2 `dep_var', rand(priceusd Nonbranded_pack warn_stick ///
		illegal none) id(id2) group(c_id) nclasses(2) seed(1) 		///
		ltolerance(0.001) membership(`mem_vars') from(start)
	estimates store betas_res_`tab_design'_`smoker'
	
	** c. Compute the willingness to pay 
	nlcom (c1_plain: _b[Class1:Nonbranded_pack] / (-1 * _b[Class1:priceusd])) ///
		  (c2_plain: _b[Class2:Nonbranded_pack] / (-1 * _b[Class2:priceusd])) ///
		  (c1_stick: _b[Class1:warn_stick] / (-1 * _b[Class1:priceusd])) ///
		  (c2_stick: _b[Class2:warn_stick] / (-1 * _b[Class2:priceusd])), post
	estimates store wtp_`tab_design'_`smoker'
	
	** d. Repeat the process for the clogit option 
	clogit choice priceusd Nonbranded_pack warn_stick illegal none, /// 
		group(c_id) vce(cluster id2) 	
	estimates store betas_res_clogit_`tab_design'_`smoker'
	
	nlcom (plain: -_b[Nonbranded_pack]/_b[priceusd]) /// 
		(stick: -_b[warn_stick]/_b[priceusd]), post
	estimates store wtp_clogit_`tab_design'_`smoker'
	
restore
	
* a. WTP 
* Omit the step in case the outcome is risk
if "`dep_var'" == "choice"{
	etable, ///
	estimates(wtp_`tab_design'_`smoker' wtp_clogit_`tab_design'_`smoker') ///
	column(index) showstars showstarsnote title("(L)C-logit WTP") ///
	stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
	mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
	mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
	mstat(aic, nformat(%8.0fc) label("AIC")) ///
	mstat(bic, nformat(%8.0fc) label("BIC")) ///
	export("$carpetaMadre\\temp\\latent_class_res\\`table'A_design`tab_design'_`smoker'.xlsx", replace)
}
	
* b. Betas table
etable, ///
	estimates(betas_res_`tab_design'_`smoker' betas_res_clogit_`tab_design'_`smoker') ///
	column(index) showstars showstarsnote title("(L)C-logit coefficients") ///
	stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
	mstat(N_clust, nformat(%8.0fc) label("Respondents")) ///
	mstat(ll, nformat(%8.0fc) label("Log-Likelihood")) ///
	mstat(aic, nformat(%8.0fc) label("AIC")) ///
	mstat(bic, nformat(%8.0fc) label("BIC")) ///
	export("$carpetaMadre\\temp\\latent_class_res\\`table'B_design`tab_design'_`smoker'.xlsx", replace)