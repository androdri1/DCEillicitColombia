********************************************************************************
* Adjust the attributes dataset and define the dominated choices

// Keep the basic attributes of each of the choice sets presented
// There are 4 alternatives per choice set (alt; 3 packages + opt-out)
// 3 blocks (block), each of 7 choice sets (cset)
clear all
import excel "$carpetaMadre\\raw_data\\atributosVF6.xlsx", sheet("Hoja1") firstrow clear

foreach varo in branded_pack plain_pack illegal {
	foreach att in price warn_stick {
		gen `varo'_`att'x = `att' if `varo'==1
		bys block cset :  egen `varo'_`att' = max(`varo'_`att'x)
		drop `varo'_`att'x
	}
}

gen     dominated=0
replace dominated=1 if branded_pack_price<=price & plain_pack==1 & branded_pack_warn_stick==warn_stick				// If the plain package is at least as expensive as the branded, and same warning stick status
replace dominated=2 if branded_pack_price<=price & plain_pack==1 & branded_pack_warn_stick==0 & warn_stick==1				// If the plain package is at least as expensive as the branded, and there is warning in the plain, not in the branded
replace dominated=3 if branded_pack_price<=price & illegal==1					// If the illegal package is at least as expensive as the branded

label var dominated "Dominated choice (0 no-dominated alternative)"
label def dominated 0 "No-dominated" 1 "Plain over branded, same stick" 2 "Plain over branded, +stick warning"  3 "Illegal over branded"
label val dominated dominated

bys cset block: egen hayDominated = max(dominated)
recode hayDominated (0=0) ( 1 2 3 =1) 
label var hayDominated "Choice set includes a dominated alternative"

gen cg = illegal // Name in the Canada file

gen     pack= 0
replace pack= 1 if plain_pack==1 & warn_stick==1
replace pack= 2 if plain_pack==1 & warn_stick==0
replace pack= 3 if branded_pack==1 & warn_stick==1
replace pack= 4 if branded_pack==1 & brand_stick==1

label define pack 	0 "Opt-out | Illicit" ///
					1 "Plain with warning sticks" ///
					2 "Plain with not-branded sticks" ///
					3 "Standard with warning sticks" ///
					4 "Standard with branded sticks"
label values pack pack 
tab pack, g(pack)

/*
1: Opt-out | Illicit 
2: Plain with warning sticks
3: Plain with not-branded sticks
4: Standard with warning sticks
5: Standard with branded sticks
*/

drop branded_pack_price branded_pack_warn_stick plain_pack_price plain_pack_warn_stick illegal_price illegal_warn_stick

tempfile atributos
save `atributos' 

count // 84 alternatives presented in total

preserve
duplicates drop cset block , force //21 choice sets presented
tab hayDominated // 3 on dominates sets
restore

duplicates drop price branded_pack plain_pack warn_stick brand_stick cg , force
tab hayDominated // 19 real alternatives, 5 of them on dominated sets 
tab dominated    // Only 3 dominated alternatives


********************************************************************************
* Import the dataset
import excel "$carpetaMadre\\raw_data\\results-survey656866-modified.xlsx", sheet("results-survey656866-modified") firstrow clear

// Estas encuestas no hacen parte del panel
drop if refurl=="https://encuestas.urosario.edu.co/"
drop if refurl=="https://encuestas.urosario.edu.co/index.php/656866"


drop if Q026=="" & Q026NF=="" // No completadas
drop if Q027=="" // No completadas
*#1
gen choice1 = Q011
replace choice1 = Q011NF if Q011==""
gen choiceOt1=Q011NFother
gen safe1 = Q012
*#2
gen choice2 = Q014
replace choice2 = Q014NF if Q014==""
gen choiceOt2=Q014NFother
gen safe2 = Q015

*#3
gen choice3 = Q017
replace choice3 = Q017NF if Q017==""
gen choiceOt3=Q017NFother
gen safe3 = Q018
*#4
gen choice4 = Q020
replace choice4 = Q020NF if Q020==""
gen choiceOt4=Q020NFother
gen safe4 = Q021
*#5
gen choice5 = QBloque7P1 // error
replace choice5 = QBloque7P1NF if QBloque7P1==""
gen choiceOt5=QBloque7P1NFother
gen safe5 = QBloque7P1S
*#6
gen choice6 = Q023
replace choice6 = Q023NF if Q023==""
gen choiceOt6=Q023NFother
gen safe6 = Q024
*#7
gen choice7 = Q026
replace choice7 = Q026NF if Q026==""
gen choiceOt7=Q026NFother
gen safe7 = Q027
*labels
forval i=1/7 {
	replace choice`i'="Ninguna de las anteriores" if choice`i'=="Otro"
	encode choice`i', gen(c`i')
	encode safe`i', gen(s`i')
	}
rename EncuestaRandnumber block
ta block


** Count the amount of observations per block
eststo block_n: estpost tabstat block, by(block) statistics(n)
//esttab block_n using "$carpetaMadre\\created_data\\tables\\n_per_block.doc", replace cells("count") noobs


rename Q003 age
sum age, d
gen smoker1 = (Q002=="Diariamente" | Q002=="Ocasionalmente")
ta smoker1
gen smoker2 = (FUMO=="Sí")
ta smoker1 smoker2
gen smoker = (smoker1==1 | smoker2==1)
ta smoker
egen id2 = seq()
	
	
tab Q061, gen(sex)
rename sex1 male
gen ecig= ECIG=="Sí"

/* Generate the income indicator based on the previous levels 
gen lowinc= inc_5==1 | inc_4==1 if inc_5!=.
gen highinc= inc_1==1 | inc_2==1 | inc_3==1 | inc_6==1 if inc_1!=.
inc_4 and inc_5 corresponded to less than one million 
inc_1, inc_2, inc_3, inc_6 corresponded to more than one million
*/

generate lowinc = (Q059<1000000)
generate highinc = (Q059>1000000)


tab Q060, gen(edu_)
gen college = edu_5== 1 	
gen technical = edu_6 == 1 
gen high_school = edu_1==1

encode Q064A, gen(city)

gen capital= city==5 if city!=.

* Renaming the variables
rename Q002 smoking_status
rename Quéedadteníaustedcuandofum start_age
rename Compróunacajetilladecigarri bought_last_30
rename Cuálfueelprecioquepagóla last_price
rename Cuántoscigarrilloshabíaenes q_last_pckg
rename Cuántosdíashafumadocigarril q_days_last_m
rename AproximadamenteCuántoscigarr cigs_x_day
rename Enlosúltimos12mesesDejód drop_last_year
rename Quéedadteníaustedcuandolos ECIG_start_age
rename Q060 educ_level

* Generating new variables for the descriptive statistics
// Smoking status
generate used_to =(smoking_status=="Ahora no fumo, pero solía fumar")
generate daily =(smoking_status=="Diariamente")
generate never =(smoking_status=="Nunca he fumado")
generate ocasionally =(smoking_status=="Ocasionalmente")

// Buyer in the last month
generate buyer_last_30 = (bought_last_30=="Sí")
drop bought_last_30
rename buyer_last_30 bought_last_30

// Respondent tried to quit smoking in the last year
generate quit_last_year = (drop_last_year == "Sí")
drop drop_last_year
rename quit_last_year drop_last_year

// Grouping by ages and smoking status, labelling each group 
generate internal_group = 1 if (age<=25 & smoker==1)
replace internal_group = 2 if  (age>25 & smoker==1)
replace internal_group = 3 if  (smoker!=1)

label define int_g_lab 	1 "Young smoker" ///
						2 "Adult smoker" ///
						3 "Non-smoker"
label values internal_group int_g_lab 	

// Replace missing values for 0's for the Non-smokers
replace cigs_x_day = 0 if (internal_group == 3 & cigs_x_day == . )



********************************************************************************	
// Descriptive stats ...........................................................

tabstat smoker age male ecig lowinc highinc college capital , by(block) stat(mean)
tabstat smoker age male ecig lowinc highinc college capital , by(smoker) stat(mean)	

* Label the variables
label variable internal_group "Respondent type"
label variable used_to "Used to"
label variable daily "Daily"
label variable never "Never"
label variable ocasionally "Occasionally"
label variable bought_last_30 "Bought cig. last month"
label variable cigs_x_day "Cig. per day"
label variable smoker "Smoker"
label variable age "Age"
label variable start_age "First time age"
label variable male "Male"
label variable ecig "Tried e-cig."
label variable lowinc "Low Inc."
label variable highinc "High Inc."
label variable college "Undergrad. or higher"
label variable technical "Technical degree"
label variable high_school "High school"
label variable capital "Capital"
label variable drop_last_year "Tried to drop last year"
label define smokers_lab 0 "Non-smoker" 1 "Smoker"
label values smoker smokers_lab


// Keep the data for creating the descriptive statistics
save "$carpetaMadre\\created_data\\data_for_descriptive_stats.dta", replace
********************************************************************************	
// We need to reshape the dataset as table 3.6 in Ryan et al...................
use "$carpetaMadre\\created_data\\data_for_descriptive_stats.dta", clear
keep id2 block c1-s7 age smoker smoker1 smoker2 interviewtime  choiceOt*

reshape long c s choiceOt, i(id2 block age smoker smoker1 smoker2) j(cset) 
egen c_id = seq()
expand 4
bys id2 cset block: egen alt = seq()
gen choice = (c == alt)
gen safe = (s == alt) 

*Add back the choice set attributes
merge m:1 alt cset block using `atributos' , nogen


label var alt    "Alternative number in the choice set"
label var cset   "Choice set number"
label var block  "Blocks (1&2 with illicit alt) and 3 (no-illicit alt) "
label var c_id   "Individual + choice set identifier"
label var id2     "Individual identifier"
label var choice "Indicator of preferred choice"    
label var safe   "Indicator of less healthy"
label var choiceOt "Reason for 'other' as choice"

sort   c_id id2 block cset alt choice safe
order  c_id id2 block cset alt choice safe


********************************************************************************
* Dominance
tab dominated if choice==1 & hayDominated==1 // Around 13.5% of the choices where a dominated alternative was available, result in the dominated choice

gen none= alt==4
label var none "Optout alternative"

* Chosen alternatives
tabstat  branded_pack plain_pack warn_stick brand_stick cg price none if choice==1 & (block==1 | block==2) , statistics( mean sum)
tabstat  branded_pack plain_pack warn_stick brand_stick cg price none if choice==1 & (block==3) , statistics( mean sum)

* Chosen alternatives
rename none optout
tabstat  branded_pack plain_pack warn_stick brand_stick illegal price optout if choice==1 & (block==1 | block==2) , statistics( mean sum)
tabstat  branded_pack plain_pack warn_stick brand_stick illegal price optout if choice==1 & (block==3) , statistics( mean sum)
rename optout none

* Pack type identifiers for table requested by referee 
generate pack_type_id = pack
replace pack_type_id = -1 if none == 1
label define pack_type_id 		-1 "Opt-out" ///
								0 "Illicit" ///
								1 "Plain with warning sticks" ///
								2 "Plain with not-branded sticks" ///
								3 "Standard with warning sticks" ///
								4 "Standard with branded sticks"
label values pack_type_id pack_type_id 

********************************************************************************
* Model estimate (ver Col)
gen priceusd= price/3800
label var priceusd "Price in USD, July 2021"

gen priceDM=priceusd*(1-cg)
gen priceCG=priceusd*cg

label var priceDM "Price in USD (Lucky)"
label var priceCG "Price in USD (Illicit)"

* Create a dummy for those of design #2 and different interactions 
generate D2 = (block==3)
generate pDMxD2 = priceDM*D2
generate brandedxD2 = branded_pack*D2
generate warningxD2 = warn_stick*D2

// Keep the data for the running the regressions
save "$carpetaMadre\\created_data\\data_for_regs.dta", replace

********************************************************************************
** Auction data processing
* Import the original dataset again
import excel "$carpetaMadre\\raw_data\\results-survey656866-modified.xlsx", sheet("results-survey656866-modified") firstrow clear

* Set the respondent's block and id2
rename EncuestaRandnumber block
rename Q003 age
egen id2 = seq()

* Reorganize the smoking condition
generate smoker1 = (Q002=="Diariamente" | Q002=="Ocasionalmente")
tabulate  smoker1
generate smoker2 = (FUMO=="Sí")
tabulate smoker1 smoker2

generate  smoker = (smoker1==1 | smoker2==1)
tabulate smoker


*Grouping by ages and smoking status, labelling each group 
generate internal_group = 1 if (age<=25 & smoker==1)
replace internal_group = 2 if  (age>25 & smoker==1)
replace internal_group = 3 if  (smoker!=1)

label define int_g_lab 	1 "Young smoker" ///
						2 "Adult smoker" ///
						3 "Non-smoker"
label values internal_group int_g_lab 	


* Workout the auctions 
rename Q044 auction1
summarize auction1
rename Q045 auction2
summarize auction2

// If participant i bids less for (discounts) the cigarettes with the more prominent label, we define this as Di = 1
* This dummy shows when the information made the participant bid less on the cigarrette package
generate D = (auction1>auction2) if auction1!=. & auction2!=.  
bys block: sum D
bys block: sum D if smoker==1

* The willingness to pay in order to avoid the packages is equivalent to the value of information (Dif in auctions)
generate wtp_auction=auction2-auction1
summarize wtp_auction, d

* Calculate the value in dollars
generate auctionusd =wtp_auction/3800
tabulate block
tabulate block if wtp_auction!=.

* Reorganize the data for plotting as in Rousou, et al. (2014). 
sort block wtp_auction
egen partic_i1= seq() if wtp_auction!=. & block==1
egen partic_i2= seq() if wtp_auction!=. & block==2
egen partic_i3= seq() if wtp_auction!=. & block==3

* Relabel the variables
la var partic_i1 "Partic. i"
la var partic_i2 "Partic. i"
la var partic_i3 "Partic. i"
la var wtp_auction "WTP{superscript:i}{subscript:1}-WTP{superscript:i}{subscript:0}"

* Save the data for the plots
save "$carpetaMadre\\created_data\\data_for_wtp_plots.dta", replace

* Rename important variables for the VOI calculations
rename Q059 income
rename Q002 smoking_status
rename Quéedadteníaustedcuandofum start_age
rename Compróunacajetilladecigarri bought_last_30
rename Cuálfueelprecioquepagóla last_price
rename Cuántoscigarrilloshabíaenes q_last_pckg
rename Cuántosdíashafumadocigarril q_days_last_m
rename AproximadamenteCuántoscigarr cigs_x_day
rename Enlosúltimos12mesesDejód drop_last_year
rename Quéedadteníaustedcuandolos ECIG_start_age
rename Q060 educ_level

* Generate missing variables 
generate cigs_x_year = cigs_x_day*360

save "$carpetaMadre\\created_data\\data_for_voi.dta", replace