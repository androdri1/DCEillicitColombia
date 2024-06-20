*******************************************************************************
* Load the data for descriptive statistics
use "$carpetaMadre\created_data\data_for_descriptive_stats.dta", clear

* Create Table 2 of the paper, before editing variables labels and pivoting
asdoc tabstat age male high_school technical college lowinc highinc ///
never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig, /// 
by(internal_group) stat(mean sd) ///
save($carpetaMadre\\created_data\\tables_main\\table_2.doc)     ///
replace title(Respondents characteristics) dec(2) label fs(10) font(Times New Roman)

* Create Table A1 of the appendix, before editing variables labels and pivoting
asdoc tabstat age male high_school technical college lowinc highinc ///
never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig, /// 
by(block) stat(mean sd) ///
save($carpetaMadre\\created_data\\tables_appendix_A\\table_A1.doc) ///
	replace title(Covariates by block) dec(4) label fs(10) font(Times New Roman)

// Checking the amount of smokers non smokers per block 
tabstat smoker, by(block) stat(N)

/*
asdoc tabstat smoker age male ecig lowinc highinc college capital, by(block) stat(mean) ///
save($carpetaMadre\\created_data\\tables\\desc_stats_block.doc) replace title(Covariates by block) dec(4) label fs(10) font(Times New Roman)

asdoc tabstat age male ecig lowinc highinc college capital , by(smoker) stat(mean)	///
save($carpetaMadre\\created_data\\tables\\desc_stats.doc) append title(Covariates for smokers and non-smokers) dec(4) label fs(10) font(Times New Roman)
*/

*******************************************************************************
* Response time
gen timMin=interviewtime/60
sum timMin

egen DCEtime = rowtotal( TemporizacióndelgrupoEjemplo- TemporizacióndelapreguntaWH)
replace DCEtime=DCEtime/60
sum DCEtime, d

egen Auctiontime = rowtotal( IE- JN)
replace Auctiontime=Auctiontime/60
sum Auctiontime, d


*******************************************************************************
* Generate table 2 of the appendix before minor edits
	*t-stats per respondent type
	* Young smokers vs Adult smokers 
	preserve 
	keep if (internal_group == 1 | internal_group ==2)

	estpost ttest age male high_school technical college lowinc highinc ///
	never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig, /// 
	by(internal_group)
	eststo young_adult
	
	restore
	
	*Young smokers Vs. non-smokers
	preserve 
	keep if (internal_group == 1 | internal_group == 3)

	estpost ttest age male high_school technical college lowinc highinc never ///
	used_to ocasionally daily cigs_x_day drop_last_year ecig, /// 
	by(internal_group)
	eststo young_nons
	 
	restore
	
	* Adult smokers Vs. non-smokers
	preserve 
	keep if (internal_group == 2 | internal_group == 3)

	estpost ttest age male high_school technical college lowinc highinc never ///
	used_to ocasionally daily cigs_x_day drop_last_year ecig, /// 
	by(internal_group)

	 eststo adult_nons
	 
	restore
	
	* Genearting the table 
	esttab young_adult young_nons adult_nons ///
		using "$carpetaMadre\created_data\\tables_appendix_A\\table_A2.csv", ///
		wide ///
		mtitles("Young vs. Adult. smokers" "Young smokers vs. Non-smokers." "Adult smokers vs. Non-smokers.") ///
		title("Appendix 2. Mean differences of characteristics per respondent type") ///
		addnotes("Significance level: * p<0.05  ** p<0.01  *** p<0.001") label replace
	

* Generate table 3 of the appendix before minor edits
	*t-stats per respondent block
	* Block 1 vs block 2
	preserve 
	keep if (block == 1 | block ==2)

	estpost ttest age male high_school technical college lowinc highinc ///
	never used_to ocasionally daily cigs_x_day start_age drop_last_year ecig, /// 
	by(block)
	eststo b1_vs_b2
	
	restore
	
	* Block 1 vs block 3
	preserve 
	keep if (block == 1 | block== 3)

	estpost ttest age male high_school technical college lowinc highinc never ///
	used_to ocasionally daily cigs_x_day drop_last_year ecig, /// 
	by(block)
	eststo b1_vs_b3
	 
	restore
	
	
	
	* Block 2 vs block 3
	preserve 
	keep if (block == 2 | block == 3)

	estpost ttest age male high_school technical college lowinc highinc never ///
	used_to ocasionally daily cigs_x_day drop_last_year ecig, /// 
	by(block)

	 eststo b2_vs_b3
	 
	restore
	
	* Genearting the table 
	esttab b1_vs_b2 b1_vs_b3 b2_vs_b3 ///
	using "$carpetaMadre\created_data\\tables_appendix_A\\table_A3.csv", ///
		wide ///
		mtitles("Block 1 vs. Block 2" ///
			"Block 1 vs Block 3" "Block 2 vs. Block 3") ///
		title("Appendix 3. Mean differences of characteristics per block") ///
		addnotes("Significance level: * p<0.05  ** p<0.01  *** p<0.001") label replace
	
////////////////////////////////////////////////////////////////////////////////
use "$carpetaMadre\\created_data\\data_for_regs.dta", clear

/*
1: Opt-out | Illicit 
2: Plain with warning sticks
3: Plain with not-branded sticks
4: Standard with warning sticks
5: Standard with branded sticks
*/

* Dominated choices ............................................................
count // 84 alternatives presented in total

preserve
duplicates drop cset block , force //21 choice sets presented
tab hayDominated // 3 on dominates sets
restore

preserve
duplicates drop price branded_pack plain_pack warn_stick brand_stick cg , force
tab hayDominated // 19 real alternatives, 5 of them on dominated sets 
tab dominated    // Only 3 dominated alternatives
restore
*..........

* Dominance
tab dominated if choice==1 & hayDominated==1 // Around 13.5% of the choices where a dominated alternative was available, result in the dominated choice
gen AlgunDomx = (dominated==1 | dominated==2 | dominated==3) & choice==1
bys id2: egen AlgunDom=max(AlgunDomx)
preserve // Por persona
tab AlgunDom // 365       20.73
restore

