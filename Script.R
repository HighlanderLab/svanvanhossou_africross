###-----  Set up the environment ------
options(warn = 1, bitmapType='cairo')
setwd( getwd() )
.libPaths("/scratch/agKoenig/vanvanhossous/r_lib")
rm(list = ls())

###----- Load packages & functions ------
library(package = "AlphaSimR")
source("Functions.R")


###---------------------------------------------------------------------------------
#                          Simulation with 40 replicates 
###---------------------------------------------------------------------------------
#for (Rep in 1:40){
for (Rep in 1:5){
      
###----- Simulation of founder populations -----
 source("CreateFounderPops.R")
      
###----- Simulation of local and exotic breeds -----
 source("CreateLocal&ExoticBreeds.R")
    
###----- Export phenotypic and genetic values for each generation -----
  write.table(Summary_LocalBreed, "Summary_LocalBreed.txt", append = T, quote = F, sep = "\t",  row.names = F, col.names = F)
  write.table(Summary_ExoticBreed, "Summary_ExoticBreed.txt", append = T, quote = F, sep = "\t",  row.names = F , col.names = F)
###----- Export the population parameters -----
  write.table(Fst, "Fst.txt", append = T, quote = F, sep = "\t",  col.names = F)
  write.table(HetFounders, "HetFounders.txt", append = T, quote = F, sep = "\t",  col.names = F)
  write.table(HetLocalFounders, "HetLocalFounders.txt", append = T, quote = F, sep = "\t",  col.names = F)  
}