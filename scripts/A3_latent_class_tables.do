** Setting up the directory for writing the needed tables
cd "$carpetaMadre\\temp\\latent_class_res"

* Latent classes logit

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
	*local mem_vars age male high_school technical college lowinc highinc 
	
	
* Latent class model - purchase descisions & risk perceptions	
* Iterate on the design 
**foreach dep_var in choice { 
foreach dep_var in choice safe{
	
	* Define the table that will be written
	if "`dep_var'" == "choice"{
		local table = "A8B"
	}
	else{
		local table = "A9"
	}
	
	
foreach design in A B{
	foreach smoker in ns s{
		
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

** Run the conditional logit model on the dependent variable
asdoc lclogit2 `dep_var', rand(priceusd Nonbranded_pack warn_stick illegal ///
	none) id(id2) group(c_id) nclasses(2) seed(1) nolog ///
	ltolerance(0.001) membership(`mem_vars') ///
	save(table_`table'_panel_a_design_`tab_design'_`smoker'.doc) replace


** Checking the posterior probabilities
by `e(id)', sort: generate first = _n==1
lclogitpr2 cp, cp
egen double cpmax = rowmax(cp1-cp2)
summarize cpmax if first, sep(0)

** Predict the classes for each respondent following the lclogit guide
lclogitpr2 pr, pr
generate byte class = .

forvalues c = 1/`e(nclasses)' {
quietly replace class = `c' if cpmax==cp`c'
}

** Collapse the classes for later merging
collapse (mean) class, by(id2)

** Save the assigned classes in a temporary file 
tempfile assigned_classes
save `assigned_classes'

** Loading the descriptive stats file
use "$carpetaMadre\\created_data\\data_for_descriptive_stats.dta", clear

** Keep the target variables from this file
keep id2 age male high_school technical college lowinc highinc ///
never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig smoker

** Merge the characteristics file with the assigned classes and keep the coincidences
merge 1:1 id2 using `assigned_classes', keep(3)

** Generate the descriptive statistics
asdoc tabstat age male high_school technical college lowinc highinc ///
	never used_to ocasionally daily cigs_x_day start_age drop_last_year ///
	ecig, by(class) stat(mean sd) ///
	save($carpetaMadre\temp\\latent_class_res\\table_`table'_panel_b_design_`tab_design'_`smoker'.doc) ///
	replace title (Design `design' `s' `dep_var') dec(2) label fs(10) ///
	font(Times New Roman)		
	
restore
		}
	}
}


/*

* Iterate on the smoking status 
local smoker s 

* Iterate on the dependent variable
local dep_var choice

* Select the sample depending on the characteristics
if "`design'" == "A"{
	keep if D2 == 1
}
else{
	keep if D2 == 0	
}

if "`smoker'" == "`s'"{
	keep if smoker == 1
}
else{
	keep if smoker == 0 
}

** Run the conditional logit model on the dependent variable
asdoc lclogit2 `dep_var', rand(priceusd Nonbranded_pack warn_stick illegal ///
	none) id(id2) group(c_id) nclasses(2) seed(1) nolog ///
	ltolerance(0.001) membership(`mem_vars') ///
	save(latent_class_`design'_`s'_`dep_var'.doc) replace


** Checking the posterior probabilities
by `e(id)', sort: generate first = _n==1
lclogitpr2 cp, cp
egen double cpmax = rowmax(cp1-cp2)
summarize cpmax if first, sep(0)

** Predict the classes for each respondent following the lclogit guide
lclogitpr2 pr, pr
generate byte class = .

forvalues c = 1/`e(nclasses)' {
quietly replace class = `c' if cpmax==cp`c'
}

** Collapse the classes for later merging
collapse (mean) class, by(id2)

** Save the assigned classes in a temporary file 
tempfile assigned_classes
save `assigned_classes'

** Loading the descriptive stats file
use "$carpetaMadre\\created_data\\data_for_descriptive_stats.dta", clear

** Keep the target variables from this file
keep id2 age male high_school technical college lowinc highinc ///
never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig smoker ///
block

** Merge the characteristics file with the assigned classes and keep the coincidences
merge 1:1 id2 using `assigned_classes', keep(3)

** Generate the descriptive statistics
asdoc tabstat age male high_school technical college lowinc highinc ///
	never used_to ocasionally daily cigs_x_day start_age drop_last_year ///
	ecig, by(class) stat(mean sd) ///
	save($carpetaMadre\created_data\\temp2\\desc_stats_design`design'_`s'_`dep_var'.doc) ///
	replace title (Design `design' `s' `dep_var') dec(2) label fs(10) ///
	font(Times New Roman)

	
/*
	asdoc tabstat age male high_school technical college lowinc highinc ///
	never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig, /// 
	by(class) stat(mean sd) ///
	save($carpetaMadre\\created_data\\tables\\desc_stats_d1_non_s_classes.doc)     ///
	replace title(Design 1 non smokers classes) dec(2) label fs(10) font(Times New Roman)
	

