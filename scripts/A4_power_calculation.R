# Description: This file computes the power calculation matrix

#=========================================================================================
## Needed packages
if (!require("pacman")) install.packages("pacman"); library(pacman)
p_load(dplyr, rstudioapi)


#=========================================================================================
## Paths definitions
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
temp_path<-"./../temp/"


#=========================================================================================
## Trial for Design A, Nonsmokers - Column 1 of Table 4 in the manuscript
# Note that this is done with the coefficients and not the marginal effects

# Box 1 in the suggested paper
test_alpha=0.05
z_one_minus_alpha<-qnorm(1-test_alpha)

# Box 2 in the suggested paper
test_beta=0.20
z_one_minus_beta<-qnorm(1-test_beta)


#= Design A - Nonsmokers ==========

# Box 3 in the suggested paper
parameters<-c(- 0.3915465, #priceusd
              - 2.206457,  #Nonbranded_pack
              - 0.3761769, # warn_stick 
              -17.94449)   #none

# Box 4 in the suggested paper
ncoefficients=4
nalts=4
nchoices=7

# Box 5 in the suggested paper
# Load the matrix
design<-read.csv(paste0(temp_path, 
                        "power_mat.csv")) %>% 
  # Filter to the specific column data 
  filter(smoker == "Non-smoker" & block == 3) %>% 
  # Sort the data
  arrange(c_id, cset, alt) %>% 
  # Select the columns that will be employed for computation
  select(priceusd, Nonbranded_pack, warn_stick, none) %>% 
  as.matrix()

# Box 6 in the suggested paper
#compute the information matrix, see Appendix (Electronic Supplementary Material 2) for more details
# initialize a matrix of size ncoefficients by ncoefficients filled with zeros.
info_mat=matrix(rep(0,ncoefficients* ncoefficients), ncoefficients, ncoefficients)
# compute exp(design matrix times initial parameter values)
exputilities=exp(design%*%parameters)
# loop over all choice sets
for (k_set in 1:nchoices) {
  # select alternatives in the choice set
  alternatives=((k_set-1)*nalts+1) : (k_set*nalts)
  # obtain vector of choice shares within the choice set
  p_set=exputilities[alternatives]/sum(exputilities[alternatives])
  # also put these probabilities on the diagonal of a matrix that only contains zeros
  p_diag=diag(p_set)
  # compute middle term P-pp’ in equation A.1 of Electronic Supplementary Material 2
  middle_term<-p_diag-p_set%o%p_set
  # pre- and postmultiply with the Xs from the design matrix for the alternatives in this choice set
  full_term<-t(design[alternatives,])%*%middle_term%*%design[alternatives,]
  # Add contribution of this choice set to the information matrix
  info_mat<-info_mat+full_term
} # end of loop over choice sets
#get the inverse of the information matrix (i.e., gets the variance-covariance matrix)
sigma_beta<-solve(info_mat,diag(ncoefficients))

# Box 7 in the suggested papers
# Use the parameter values as effect size. Other values can be used here.
effectsize<-parameters
# formula for sample size calculaon is n>[(z_(beta)+z_(1-alpha))*sqrt(Σγκ)/delta]^2
N<-((z_one_minus_beta + z_one_minus_alpha)*sqrt(diag(sigma_beta))/abs(effectsize))^2

# Display results
"required sample size for each coefficient"
N

#1 8.183473e+01
#2 1.971589e+00
#3 6.361059e+01
#4 6.750239e+05



#= Design A - Smokers ==========

# Box 3 in the suggested paper
parameters<-c(- 0.857, #priceusd
              - 1.534,  #Nonbranded_pack
                0.257, # warn_stick 
               -2.737)   #none

# Box 4 in the suggested paper
ncoefficients=4
nalts=4
nchoices=7

# Box 5 in the suggested paper
# Load the matrix
design<-read.csv(paste0(temp_path, 
                        "power_mat.csv")) %>% 
  # Filter to the specific column data 
  filter(smoker == "Smoker" & block == 3) %>% 
  # Sort the data
  arrange(c_id, cset, alt) %>% 
  # Select the columns that will be employed for computation
  select(priceusd, Nonbranded_pack, warn_stick, none) %>% 
  as.matrix()

# Box 6 in the suggested paper
#compute the information matrix, see Appendix (Electronic Supplementary Material 2) for more details
# initialize a matrix of size ncoefficients by ncoefficients filled with zeros.
info_mat=matrix(rep(0,ncoefficients* ncoefficients), ncoefficients, ncoefficients)
# compute exp(design matrix times initial parameter values)
exputilities=exp(design%*%parameters)
# loop over all choice sets
for (k_set in 1:nchoices) {
  # select alternatives in the choice set
  alternatives=((k_set-1)*nalts+1) : (k_set*nalts)
  # obtain vector of choice shares within the choice set
  p_set=exputilities[alternatives]/sum(exputilities[alternatives])
  # also put these probabilities on the diagonal of a matrix that only contains zeros
  p_diag=diag(p_set)
  # compute middle term P-pp’ in equation A.1 of Electronic Supplementary Material 2
  middle_term<-p_diag-p_set%o%p_set
  # pre- and postmultiply with the Xs from the design matrix for the alternatives in this choice set
  full_term<-t(design[alternatives,])%*%middle_term%*%design[alternatives,]
  # Add contribution of this choice set to the information matrix
  info_mat<-info_mat+full_term
} # end of loop over choice sets
#get the inverse of the information matrix (i.e., gets the variance-covariance matrix)
sigma_beta<-solve(info_mat,diag(ncoefficients))

# Box 7 in the suggested papers
# Use the parameter values as effect size. Other values can be used here.
effectsize<-parameters
# formula for sample size calculaon is n>[(z_(beta)+z_(1-alpha))*sqrt(Σγκ)/delta]^2
N<-((z_one_minus_beta + z_one_minus_alpha)*sqrt(diag(sigma_beta))/abs(effectsize))^2

# Display results
"required sample size for each coefficient"
N
#12.336058  2.748266 97.499251 10.161476


#= Design B - Nonsmokers ==========

# Box 3 in the suggested paper
parameters<-c(- 0.167, #priceusd
              - 2.031,  #Nonbranded_pack
              - 0.159, # warn_stick 
                1.758, # Illicit
              -18.051)   #none

# Box 4 in the suggested paper
ncoefficients=5
nalts=4
nchoices=7

# Box 5 in the suggested paper
# Load the matrix
design<-read.csv(paste0(temp_path, 
                        "power_mat.csv")) %>% 
  # Filter to the specific column data 
  filter(smoker == "Non-smoker" & (block == 1 | block == 2) ) %>% 
  # Sort the data
  arrange(c_id, cset, alt) %>% 
  # Select the columns that will be employed for computation
  select(priceusd, Nonbranded_pack, warn_stick, illegal, none) %>% 
  as.matrix()

# Box 6 in the suggested paper
#compute the information matrix, see Appendix (Electronic Supplementary Material 2) for more details
# initialize a matrix of size ncoefficients by ncoefficients filled with zeros.
info_mat=matrix(rep(0,ncoefficients* ncoefficients), ncoefficients, ncoefficients)
# compute exp(design matrix times initial parameter values)
exputilities=exp(design%*%parameters)
# loop over all choice sets
for (k_set in 1:nchoices) {
  # select alternatives in the choice set
  alternatives=((k_set-1)*nalts+1) : (k_set*nalts)
  # obtain vector of choice shares within the choice set
  p_set=exputilities[alternatives]/sum(exputilities[alternatives])
  # also put these probabilities on the diagonal of a matrix that only contains zeros
  p_diag=diag(p_set)
  # compute middle term P-pp’ in equation A.1 of Electronic Supplementary Material 2
  middle_term<-p_diag-p_set%o%p_set
  # pre- and postmultiply with the Xs from the design matrix for the alternatives in this choice set
  full_term<-t(design[alternatives,])%*%middle_term%*%design[alternatives,]
  # Add contribution of this choice set to the information matrix
  info_mat<-info_mat+full_term
} # end of loop over choice sets
#get the inverse of the information matrix (i.e., gets the variance-covariance matrix)
sigma_beta<-solve(info_mat,diag(ncoefficients))

# Box 7 in the suggested papers
# Use the parameter values as effect size. Other values can be used here.
effectsize<-parameters
# formula for sample size calculaon is n>[(z_(beta)+z_(1-alpha))*sqrt(Σγκ)/delta]^2
N<-((z_one_minus_beta + z_one_minus_alpha)*sqrt(diag(sigma_beta))/abs(effectsize))^2

# Display results
"required sample size for each coefficient"
N
#[1] 2.905716e+02 4.106397e+00 4.537068e+02 7.080818e+00 1.845112e+06


#= Design B - Smokers ==========

# Box 3 in the suggested paper
parameters<-c(- 0.474, #priceusd
              - 1.497,  #Nonbranded_pack
                0.106, # warn_stick 
               -0.197, # Illicit
               -1.873)   #none

# Box 4 in the suggested paper
ncoefficients=5
nalts=4
nchoices=7

# Box 5 in the suggested paper
# Load the matrix
design<-read.csv(paste0(temp_path, 
                        "power_mat.csv")) %>% 
  # Filter to the specific column data 
  filter(smoker == "Smoker" & (block == 1 | block == 2) ) %>% 
  # Sort the data
  arrange(c_id, cset, alt) %>% 
  # Select the columns that will be employed for computation
  select(priceusd, Nonbranded_pack, warn_stick, illegal, none) %>% 
  as.matrix()

# Box 6 in the suggested paper
#compute the information matrix, see Appendix (Electronic Supplementary Material 2) for more details
# initialize a matrix of size ncoefficients by ncoefficients filled with zeros.
info_mat=matrix(rep(0,ncoefficients* ncoefficients), ncoefficients, ncoefficients)
# compute exp(design matrix times initial parameter values)
exputilities=exp(design%*%parameters)
# loop over all choice sets
for (k_set in 1:nchoices) {
  # select alternatives in the choice set
  alternatives=((k_set-1)*nalts+1) : (k_set*nalts)
  # obtain vector of choice shares within the choice set
  p_set=exputilities[alternatives]/sum(exputilities[alternatives])
  # also put these probabilities on the diagonal of a matrix that only contains zeros
  p_diag=diag(p_set)
  # compute middle term P-pp’ in equation A.1 of Electronic Supplementary Material 2
  middle_term<-p_diag-p_set%o%p_set
  # pre- and postmultiply with the Xs from the design matrix for the alternatives in this choice set
  full_term<-t(design[alternatives,])%*%middle_term%*%design[alternatives,]
  # Add contribution of this choice set to the information matrix
  info_mat<-info_mat+full_term
} # end of loop over choice sets
#get the inverse of the information matrix (i.e., gets the variance-covariance matrix)
sigma_beta<-solve(info_mat,diag(ncoefficients))

# Box 7 in the suggested papers
# Use the parameter values as effect size. Other values can be used here.
effectsize<-parameters
# formula for sample size calculaon is n>[(z_(beta)+z_(1-alpha))*sqrt(Σγκ)/delta]^2
N<-((z_one_minus_beta + z_one_minus_alpha)*sqrt(diag(sigma_beta))/abs(effectsize))^2

# Display results
"required sample size for each coefficient"
N
#37.465240   4.091946 830.474839 455.292184  17.626003
