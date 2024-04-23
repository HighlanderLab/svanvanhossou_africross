###-----  Set up the environment ------
options(warn = 1, bitmapType='cairo')
.libPaths("/scratch/agKoenig/vanvanhossous/r_lib")

#Create directory
if (!dir.exists(paste0("./Results"))) {dir.create(paste0("./Results"))}

###----- Load packages ------
library(package = "AlphaSimR")
library(gdata)

###---------------------------------------------------------------------------------
#                          Simulation with 40 replicates 
###---------------------------------------------------------------------------------
for (Rep in 1:40){
  
rm(list = ls())
cwd = getwd()
  
###----- Load functions ------
  source("Functions.R")

###----- Simulation Parameters -----
  source("SimParameters.R")

###----- Simulation of founder populations -----
  source("CreateFounderPops.R")
      
###----- Simulation of local and exotic breeds -----
  source("CreateLocal&ExoticBreeds.R")
  
###----- Simulation of local farms and villages-----
  source("CreateFarms&Villages.R")
 
###----- Crossbreeding strategies-----
 ## Composite Farm bull
  source("Cross_Composite_FB.R")  

 ## Composite Intra village bull
  source("Cross_Composite_IVB.R")  

 ## Composite Extra village bull
  source("Cross_Composite_EVB.R")  

 ## Composite Population wide bull
  source("Cross_Composite_PWB.R")
 
 ## Rotational
  source("Cross_Rotational.R")   
  
 ##Terminal
  source("Cross_Terminal.R")
 }
  

