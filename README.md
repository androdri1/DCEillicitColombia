# DCEillicitColombia

Would plain packaging and health warning labels reduce smoking in the presence of informal markets? A Choice Experiment in Colombia READ-ME file for code submitted with the manuscript
Paul Rodríguez-Lesmes, Universidad del Rosario, paul.rodriguez@urosario.edu.co 
Pamela Góngora, Oxford University, pamela.gongora@dph.ox.ac.uk 
Emmanouil Mentzakis, City, University of London, emmanouil.mentzakis@city.ac.uk 
Neil Buckley, York University, nbuckley@yorku.ca
Juan Miguel Gallego, Universidad del Rosario, juan.gallego@urosario.edu.co 
Emmanuel Guindon, McMaster University, emmanuel.guindon@mcmaster.ca 
Juan Pablo Martínez, Universidad del Rosario, juanpablo.martinez@urosario.edu.co 
Guillermo Paraje, Universidad Adolfo Ibañez, guillermo.paraje@uai.cl 

Data needed for replication and LimeSurvey questionnaire are available at: https://doi.org/10.34848/DLYZZU

## Main Programs
### Data process
1_data_process.do transforms the raw data to a format that can be used for descriptive statistics and running the regressions, as well as the value of information (VOI) computations. Prices in COP are transformed to USD using a fixed exchange rate of 3.800COP per USD. 
### Descriptive statistics
Descriptive statistics of the covariates at the respondent’s ages and blocks are built, which correspond to Tables 2 of the main paper and Tables 1 through 3 of Appendix A. 2_descriptives_tables.do generates these tables before minor editing. 
### Results – Multinomial logit
Multinomial logit models are run on 3_reg_tables.do where main results are built as well as supplementary material. Specifically, Tables 3 and 4 of the paper and Tables 4 and 5 of Appendix A. 

## Appendix A Programs
### Heterogeneities
Differential results depending on age, income and consumption patterns are presented. These results are store in table 6 of Appendix A and the script that computes these heterogeneities for each design is A1_heterogeneities.do.
### Latent class WTP
Latent class logit models are employed for computing the WTP and see whether there could be differences due to underlying characteristics of the respondents. These results are computed with A2_lclogit_wtp_w_bootstrap.do, which in turns employs two additional functions stored in func_lclogit_boostrap_program.do and func_lclogit_wtp_compute.do.
### Latent class coefficients and characteristics per class
Coefficients and descriptives for each class depending on the resulting class are presented in table 9 in Appendix A and computed with A3_latent_class_tables.do. 
### Robustness
Main results robustness checks are checked depending on the time spent responding, keeping only non-dominated options, and dropping the 7th question. The results reported on table 10 of Appendix A are computed with A4_robustness.do.

## Appendix B Programs
### VOI data set up
Value of information calculations rely upon the computation of a price different to the one respondents face, so the data base for finding this variable is generated in B_1_voi_data_process.do. The last price consumers paid when smoking is assigned in case respondents had a WTP equal to zero. 
### P^'calculations
B_2_p_p_function.nb is a wolfram mathematica notebook that executes the program for finding the specific price for each respondent. Its inputs correspond to the data file generated in the previous step. Given the necessity of having the specific program, the data is already provided in the raw_data folder.
### VOI calculations
Having all the variables for computing the VOI and fixing the price and revenue elasticities, B_3_voi_calculations.do perform the computations of the final values. Moreover, the original data with demographics data is added for later generating tables. 
### VOI tables
B_4_voi_calculations.do generates both panels of the table for VOI results. 
