# Simulation_Crossbreeding
## Simulation of founder populations
  ##### Code
    CreateFounderPops.R
  ##### Description 
In this script, we simulated 
- a cattle genome of 30 chromosome pairs for 5,000 founder individuals. Each chromosome consisted of 300 QTL and 1400 SNP.
- two complex traits with additive, dominance architecture : body weight (productive trait, moderate heritability) and tick count (adaptive trait, low heritability).

 We assumed: 
- a population split 20.000 generations ago (100.000 years as between Taurine and Indicine cattle)
- all the traits are controlled by the same QTL (correlated QTL effects)
- the same heritability in the two breeds but different phenotypic mean and variance in the two breeds, leading to 2 x 2 simulated traits
- the genetic correlation between body weight and  tick count in the same breed is 0.2
- the correlation between local and exotic environment is 0.6

## Simulation of a local and exotic breed 
  ##### Code
    CreateLocal&ExoticBreeds.R
  ##### Description 
In this script, we simulated pure breeding over 20 generations in the local and exotic breeds separately to generate trait-specific linkage-disequilibrium in each breed

We assumed 
- phenotypic selection targeting (lower) tick count for the local breed
- genomic selection targeting (higher) body weight for the exotic breed. 

## Custom functions
   ##### Code
    Functions.R
  ##### Description
 These are custom functions in R for specific tasks, e.g., calculate average phenotypic and genetic values, and further statistical analyses.
  
## Replicates
   ##### Code
    Script.R
  ##### Description
This script is used to run all the process in once with a total of 40 replicates.
