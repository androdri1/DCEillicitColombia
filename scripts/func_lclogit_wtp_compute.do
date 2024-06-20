* Compute the WTP as the ratio between estimators 
nlcom (wtp_plain_1: -_b[b_plain_1]/_b[b_price_1]) ///
	(wtp_warn_1: -_b[b_warn_1]/_b[b_price_1]) ///
	(wtp_illicit_1: -_b[b_illicit_1]/_b[b_price_1]) ///
	(wtp_plain_2: -_b[b_plain_2]/_b[b_price_2]) ///
	(wtp_warn_2: -_b[b_warn_2]/_b[b_price_2]) ///
	(wtp_illicit_2: -_b[b_illicit_2]/_b[b_price_2]), post
	
* Save the results in locals 
	* WTP estimators
	local wtp_plain_1 = e(b)[1,1]
	local wtp_warn_1 = e(b)[1,2]
	local wtp_illicit_1 = e(b)[1,3]
	local wtp_plain_2 = e(b)[1,4]
	local wtp_warn_2 = e(b)[1,5]
	local wtp_illicit_2 = e(b)[1,6]

	* SE estimators 
	local se_plain_1 = sqrt(e(V)[1,1])
	local se_warn_1 = sqrt(e(V)[2,2])
	local se_illicit_1 = sqrt(e(V)[3,3])
	local se_plain_2 = sqrt(e(V)[4,4])
	local se_warn_2 = sqrt(e(V)[5,5])
	local se_illicit_2 = sqrt(e(V)[6,6])
	
* Estimate the conditional logit model and save the results in locals
clogit choice priceusd Nonbranded_pack warn_stick illegal none, /// 
	group(c_id) vce(cluster id2) 	
nlcom (wtp_plain: -_b[Nonbranded_pack]/_b[priceusd]) ///
	(wtp_warn: -_b[warn_stick]/_b[priceusd]) ///
	(wtp_illegal: -_b[illegal]/_b[priceusd]), post

local wtp_plain = e(b)[1,1]
local wtp_warn = e(b)[1,2]
local wtp_illicit = e(b)[1,3]

local se_plain = sqrt(e(V)[1,1])
local se_warn = sqrt(e(V)[2,2])
local se_illicit = sqrt(e(V)[3,3]) 

* Build the file name
if "$design" == "0"{
	local design "a"
}
else{
	local design "b"
}

if "$smoker" == "0"{
	local smoker "b"
}
else{
	local smoker "a"
}
local res_name "$carpetaMadre\\created_data\\tables_appendix_A\\table_A8A_panel_`smoker'_design_`design'.doc"
	

* Build the results table 
	* Setup the file 
	asdoc, row(\i, Design #, \i, \i) ///
		title(WTP smokers lclogit)  ///
		save(`res_name') replace

	* Add non-branded results 
	asdoc, row(\i, Class 1, Class 2, Clogit)
	asdoc, accum(`wtp_plain_1', `wtp_plain_2', `wtp_plain')
	asdoc, row(Non-Branded pack, $accum)

	asdoc, accum(`se_plain_1', `se_plain_2', `se_plain')
	asdoc, row(\i, $accum)

	* Add warning stick results 
	asdoc, row(\i, Class 1, Class 2, Clogit)
	asdoc, accum(`wtp_warn_1', `wtp_warn_2', `wtp_warn')
	asdoc, row(Dissuasive stick, $accum)

	asdoc, accum(`se_warn_1', `se_warn_2', `se_warn')
	asdoc, row(\i, $accum)

	* Add illicit options results 
	asdoc, row(\i, Class 1, Class 2, Clogit)
	asdoc, accum(`wtp_illicit_1', `wtp_illicit_2', `wtp_illicit')
	asdoc, row(Illicit, $accum)

	asdoc, accum(`se_illicit_1', `se_illicit_2', `se_illicit')
	asdoc, row(\i, $accum)