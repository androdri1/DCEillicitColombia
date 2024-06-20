* Program for computing the latent class conditional logit 
program lclogit_estimators, rclass 
	version 17 
	
	* Run the model 
	lclogit2 choice, rand(priceusd Nonbranded_pack warn_stick ///
		illegal none) id(id2) group(c_id) nclasses(2) seed(123) nolog ///
		ltolerance(0.001) membership(`mem_vars')
	
	* Return the needed estimators
	return scalar b_price_1 = e(b)[1,1]
	return scalar b_plain_1 = e(b)[1,2]
	return scalar b_warn_1 = e(b)[1,3]
	return scalar b_illicit_1 = e(b)[1,4]
	return scalar b_price_2 = e(b)[1,6]
	return scalar b_plain_2 = e(b)[1,7]
	return scalar b_warn_2 = e(b)[1,8]
	return scalar b_illicit_2 = e(b)[1,9]
end
