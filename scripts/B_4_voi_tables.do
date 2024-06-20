** Panel A *********************************************************************
** Load the data
use "$carpetaMadre\\created_data\\data_for_voi.dta", clear

* Appendix tables (in COP) ....................................................

bys block smoker: sum Q037 // Chocorramo
bys block smoker: sum Q040 // Festival	
bys block smoker: sum auction1 // Primer paquete
bys block smoker: sum auction2 // Segundo paquete
bys block smoker: sum  wtp_auction // Computed WTP
tw (kdensity auction1)  (kdensity auction2) if block==1, scheme(plotplainblind) legend( order( 1 "1st Package" 2 "2nd Package"))
tw (kdensity auction1)  (kdensity auction2) if block==2, scheme(plotplainblind) legend( order( 1 "1st Package" 2 "2nd Package"))
tw (kdensity auction1)  (kdensity auction2) if block==3, scheme(plotplainblind) legend( order( 1 "1st Package" 2 "2nd Package")) 
graph close

* ******************************************************************************

** Rescale the diff in wtp
replace wtp_auction = wtp_auction/3800


	** Add the headers to the table 
	asdoc, row(\i, Smokers, \i, Non-smokers, \i, Both, \i) ///
	title(Panel A)  ///
	save($carpetaMadre\\created_data\\tables_appendix_B\\voi_panel_a.doc) replace

	asdoc, row(\i, Mean, SD, Mean, SD, Mean, SD)

	
	* Paul (19/07/2022) -- Esto es lo que va mejor en ese Panel A; el SE(Mean) != SD
	
	mean  wtp_auction if block==1 & smoker == 1
	mean  wtp_auction if block==2 & smoker == 1
	mean  wtp_auction if block==3 & smoker == 1
	
	mean  wtp_auction if block==1 & smoker == 0
	mean  wtp_auction if block==2 & smoker == 0
	mean  wtp_auction if block==3 & smoker == 0
	
	mean  wtp_auction if block==1
	mean  wtp_auction if block==2
	mean  wtp_auction if block==3
	
	/** Recognized product calculations
		** Smokers 
		summarize wtp_auction if block == 1 & smoker == 1
		local mean_diff = r(mean)
		local sd_diff = r(sd) 
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Non-Smokers 
		summarize wtp_auction if block == 1 & smoker == 0
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Both
		summarize wtp_auction if block == 1
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Add the first row of the table 
		asdoc, row(Recognized product, $accum)

	** Plain packaging calculations
		** Smokers 
		summarize wtp_auction if block == 2 & smoker == 1
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Non-Smokers 
		summarize wtp_auction if block == 2 & smoker == 1
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Both
		summarize wtp_auction if block == 2
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Add the first row of the table 
		asdoc, row(Plain packaging, $accum)
		
	** Warning on the stick calculations
		** Smokers 
		summarize wtp_auction if block == 3 & smoker == 1
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Non-Smokers 
		summarize wtp_auction if block == 3 & smoker == 1
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Both
		summarize wtp_auction if block == 3
		local mean_diff = r(mean)
		local sd_diff = r(sd)
		asdoc, accum(`mean_diff', `sd_diff')
		
		** Warning on the stick
		asdoc, row(Stick w/ warning, $accum)
	*/
		
				
		
** Panel B *********************************************************************
** Load the data
use "$carpetaMadre\\created_data\\data_for_voi_tables.dta", clear

** Summary statistics of price, quantity and income
summarize last_price
tabstat last_price cigs_x_day income, stat(mean sd)

** Generating the table of VOI
	** Add the headers to the table
	asdoc, row(\i, VOI, SD, N)  ///
	title(Value of information)  ///
	notes(VOI reported in USD. Average price paid by consumers of `avg_price'. ) ///
	 save($carpetaMadre\\created_data\\tables_appendix_B\\voi_panel_b.doc) replace
	 
		** VOI of legal option 
		summarize Total if block == 1
		local wtp_res = r(mean)
		local wtp_sd = r(sd)
		local wtp_n = r(N)
		asdoc, accum(`wtp_res', `wtp_sd', `wtp_n')
		asdoc, row(Legal option, $accum)
		
		** VOI of branded pack 
		summarize Total if block == 2
		local wtp_res = r(mean)
		local wtp_sd = r(sd)
		local wtp_n = r(N)
		asdoc, accum(`wtp_res', `wtp_sd', `wtp_n')
		asdoc, row(Branded pack, $accum)
		
		** VOI of warning stick 
		summarize Total if block == 3
		local wtp_res = r(mean)
		local wtp_sd = r(sd)
		local wtp_n = r(N)
		asdoc, accum(`wtp_res', `wtp_sd', `wtp_n')
		asdoc, row(Stick w/o warning, $accum)

	/*
	** Design 1 - Non-smokers
	mean Total if (block == 1 | block == 2) & smoker == 0
	local wtp_res = e(b)[1,1]
	local wtp_v = e(V)[1,1]
	local wtp_sd = sqrt(`wtp_v')
	asdoc, accum(`wtp_res', `wtp_sd')

	
	** Design 1 - Smokers
	mean Total if (block == 1 | block == 2) & smoker == 1
	local wtp_res = e(b)[1,1]
	local wtp_v = e(V)[1,1]
	local wtp_sd = sqrt(`wtp_v')
	asdoc, accum(`wtp_res', `wtp_sd')
	
	/*
	** Design 2 - Non-smokers
	mean Total if (block == 3) & smoker == 0
	local wtp_res = e(b)[1,1]
	local wtp_v = e(V)[1,1]
	local wtp_sd = sqrt(`wtp_v')
	asdoc, accum(`wtp_res', `wtp_sd')
	*/
	
	** Design 1 - Smokers
	mean Total if (block == 3) & smoker == 1
	local wtp_res = e(b)[1,1]
	local wtp_v = e(V)[1,1]
	local wtp_sd = sqrt(`wtp_v')
	asdoc, accum(`wtp_res', `wtp_sd')
	
	** Smokers and non-smoker simultaneously
	mean Total 
	local wtp_res = e(b)[1,1]
	local wtp_v = e(V)[1,1]
	local wtp_sd = sqrt(`wtp_v')
	asdoc, accum(`wtp_res', `wtp_sd')
	
	** Adding the first row - WTP with VOI
	asdoc, row(Branded pack, $accum)