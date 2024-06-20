** Server mainPath
** global carpetaMadre "/efs/users/marti326/Desktop/dce_exes/"

** Preliminaries
	** Load the data for the latent class model
	use "$carpetaMadre\\created_data\\data_for_regs.dta", clear
	
	cap log close
	log using "$carpetaMadre\\temp\\LOG_lclogit_wtp_w_bootstrap.txt", text replace

	** Merge with the descriptive stats data 
	merge m:1 id2 using ///
		"$carpetaMadre\created_data\data_for_descriptive_stats.dta", nogen

	** Define the membership variables 
	local mem_vars age male high_school technical college lowinc highinc 
	
	** Define the non-branded variables and some other indicators
	generate Nonbranded_pack= 1-branded_pack
	generate D1 = 1- D2
	generate pDMxD1     = priceusd*D1
	generate NonbrandedxD1 = Nonbranded_pack*D1
	generate warningxD1 = warn_stick*D1
	generate nonexD1    = none*D1
	
	generate young = age>=26 & age<.
	generate pDMxY        = priceusd*young
	generate NonbrandedxY = Nonbranded_pack*young
	generate warningxY    = warn_stick*young
	generate illegalxY    = illegal*young
	generate nonexY       = none*young
	
	global priceDM = 2.4 // 9000/3800
	global priceCG = 1   // 4000/3800
	
	** Label the variables for generating the regressions
	label variable priceDM "Price Legal"
	label variable priceCG "Price Illicit"
	label var priceusd "Price" //<<<<<<<

	label variable branded_pack "Branded pack"
	label variable warn_stick "Warning stick"
	label variable illegal "Illicit"
	label variable none "None"
	
	* Assign labels to the variables for Table requested by referee 
	generate design_type = D1
	label define d_type 0 "Design A (Only licit alternatives)" ///
						1 "Design B (Licit & illicit alternatives)"
	label values design_type d_type

** Bootstrapping on each "specification"
	* Execute the function with the bootstrap routine 
	do "$carpetaMadre\\scripts\\func_lclogit_boostrap_program.do"

	* Set up the bootstrap parameters 
	local n_reps 500
	local seed 123

	* Set up the sample parameters
	local i = 1 
	local j = 0
	forvalues i = 0/1{
		forvalues j = 0/1{
			timer on 1 
			global design `i' 
			global smoker `j'

			* Preserve the main sample and perform the bootstrap routine on the specification
			preserve

			keep if (design_type == $design & smoker == $smoker)
			bootstrap b_price_1 = r(b_price_1) ///
				b_plain_1 = r(b_plain_1) ///
				b_warn_1 = r(b_warn_1) ///
				b_illicit_1 = r(b_illicit_1) ///
				b_price_2 = r(b_price_2) ///
				b_plain_2 = r(b_plain_2) ///
				b_warn_2 = r(b_warn_2) ///
				b_illicit_2 = r(b_illicit_2), ///
				reps(`n_reps') seed(`seed'): lclogit_estimators

			* Compute the wtp an restore the original sampel 
			do "$carpetaMadre\\scripts\\func_lclogit_wtp_compute.do"
			timer off 1
			timer list 1 
			restore		
		}
	} 