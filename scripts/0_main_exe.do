* Paths setting
*global carpetaMadre = ".\..\"
global carpetaMadre = "C:\Users\juanm\OneDrive - Universidad del rosario\Documentos - Control Tabaco Facultad Economica\DCE\paper_files\read_me_folder"


* 1. Data pre-processing 
	do "1_data_process.do"
	
* 2. Descriptive statistics (Generates some of the tables of the appendix A)
	do "2_descriptive_tables.do"
	
* 3. Main regressions (Generates some of the tables of the appendix A)
	do "3_reg_tables.do"
	
* 4. Latent class Wiligness to pay (Commented since it's computationally intensive)
	*do "4_lclogit_w_boostrap.do"
	
* Appendix A. Supplemental material
	* A1. Main regressions w/ hetereogeneities
	do "A1_heterogeneities.do"
	
	* A2. Latent class model coefficients and descriptives
	do "A2_latent_class_tables.do"
	
	* A3. Robustness 
	do "./../../scripts/A3_robustness.do"
	
* Appendix B. Value of information calculations 
	* B1. VOI data set up 
	do "./../../scripts/B_1_voi_data_process.do"
	
	* B2. P' calculations
	* Execute the wolfram mathematica notebook "B_2_p_p_function.nb"
	
	* B3. VOI calculations
	do "./../../scripts/B_3_voi_calculations.do"
	
	* B4. VOI tables
	do "./../../scripts/B_4_voi_tables.do"