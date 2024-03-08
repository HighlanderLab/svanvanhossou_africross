###---------------------------------------------------------------------------------
#                          Pure breeding over 20 generations 
###---------------------------------------------------------------------------------
Strategy <- "PureBreeding"

###----- Local breeds  -----

## Phenotype the base population
LocalFounders = setPheno(pop = LocalFounders, h2 = h2)
 # Check parameters
varP(LocalFounders) 
varA(LocalFounders)
varG(LocalFounders)
varD(LocalFounders)
varD(LocalFounders)[1] / varP(LocalFounders)[1] #Dominance heritability for BodyWeight_local
varD(LocalFounders)[6] / varP(LocalFounders)[6] #Dominance heritability for TickCount_local

## Select initial parents - 
 # Phenotypic selection considering lower values for the trait "TickCount_local"
LocalBulls <- selectInd(LocalFounders, nInd= 100, trait = "TickCount_local", use = "pheno", sex = "M", selectTop = F)
LocalCows <- LocalFounders[LocalFounders@sex=="F"]

## Record Phenotypic and genetic values for the initial local population
Summary_LocalBreed <- recordSummary(pop = LocalFounders, year = 0)

## setup a local reference population for further computation
RefLocalPop <- LocalFounders

## Random mating and animal selection 
 # Phenotypic selection focusing on the trait "TickCount_local"
 # 100 bulls are selected within the last two generations (bulls are used for max.2 generations)
 # From generation 0 to 4 no selection of cows were applied to increase the population size of the local breed to 10.000 breeding females
 # From generation 5, 10.000 females are selected within animal from the last 5 generations (cows are used for max.5 generations)

for (Gen in 1:20){
  Offsprings = randCross2(females = LocalCows, males = LocalBulls, nCrosses = nInd(LocalCows))
  Offsprings <- setPheno (Offsprings, h2=  h2)
  Offsprings = setMisc(x = Offsprings, node = "yearOfBirth", value = Gen)
  Summary_LocalBreed <- recordSummary(data = Summary_LocalBreed, pop = Offsprings, year = Gen)
  
  RefLocalPop <- c(RefLocalPop, Offsprings)
  Candidates <- RefLocalPop[RefLocalPop@misc>= Gen - 4] #Consider only the last 5 generations for animal selections
  
  LocalBulls <- selectInd(Candidates[Candidates@misc>= Gen - 1],  #only bulls from the last two generations are selected
                          nInd=100, trait = "TickCount_local", use = "pheno", sex = "M", selectTop = F)
 
  if (Gen <= 4) { #for the first 4 generations
    LocalCows <- Candidates[Candidates@sex=="F"]  #all females are considered at this stage
  } else {
    LocalCows <- selectInd(Candidates, nInd=10000, trait = "TickCount_local", use = "pheno", sex = "F", selectTop = F)
  }
}
#save local population at Generation 20
LocalBreed20 <- Offsprings

#Calculate average breeding values for the local breed considering the simulated 20 generations
MeanBV_Local <- CalcMeanBV(RefLocalPop)
MeanDD_Local <- CalcMeanDD(RefLocalPop)


###----- Exotic breeds -----

## Phenotype the base population
ExoticFounders = setPheno(pop = ExoticFounders, h2 = h2)
 # Check parameters
varP(ExoticFounders)
varA(ExoticFounders)
varG(ExoticFounders)
varD(ExoticFounders)
varD(ExoticFounders)[11] / varP(ExoticFounders)[11] #Dominance heritability for BodyWeight_exotic
varD(ExoticFounders)[16] / varP(ExoticFounders)[16] #Dominance heritability for TickCount_exotic

## Estimate EBV for the base population
ans = RRBLUP(ExoticFounders, traits = "BodyWeight_exotic")
ExoticFounders<- setEBV(ExoticFounders, ans)

## Select initial parents for the exotic breed
 # Genomic selection considering higher values for the trait "BodyWeight_exotic"
ExoticBulls <- selectInd(ExoticFounders, nInd= 50, trait = 1, use = "ebv", sex = "M")
ExoticCows <- ExoticFounders[ExoticFounders@sex=="F"]

## Record Phenotypic and genetic values for the inital exotic population
Summary_ExoticBreed <- recordSummary(pop = ExoticFounders, year = 0)

## setup an exotic reference population for further computation
RefExoticPop <- ExoticFounders

## Random mating and animal selection in exotic breed
 # Genomic selection focusing on the trait "BodyWeight_exotic"
 # 50 bulls are selected  within animals from the last two generations (bulls are used for max. 2 generations)
 # 2.000 cows are selected of cows within animals from the last 5 generations (cows are used for max. 5 generations)

for (Gen in 1:20){
  Offsprings = randCross2(females = ExoticCows, males = ExoticBulls, nCrosses = nInd(ExoticCows))
  Offsprings <- setPheno (Offsprings, h2=  h2)
  Offsprings = setMisc(x = Offsprings, node = "yearOfBirth", value = Gen)
  Summary_ExoticBreed <- recordSummary(data = Summary_ExoticBreed, pop = Offsprings, year = Gen)

  RefExoticPop <- c(RefExoticPop, Offsprings)
  Candidates <- RefExoticPop[RefExoticPop@misc>= Gen - 4] 
  
  ## Estimate EBV for the reference population (the last 5 generations)
  ans = RRBLUP(Candidates, traits = "BodyWeight_exotic")
  Candidates <- setEBV(Candidates, ans)
  
  ExoticBulls <- selectInd(Candidates[Candidates@misc>= Gen - 1],  #only bulls from the last two generations are selected
                          nInd= 50, trait = 1, use = "ebv", sex = "M")
  ExoticCows <- selectInd(Candidates, nInd=2000, trait = 1, use = "ebv", sex = "F")
  
}


## Save exotic populations at Generation 20
ExoticBreed20 <- Offsprings
ExoticCandidates20 <- Candidates[Candidates@misc== 20]

#Calculate average breeding values for the exotic breed considering the simulated 20 generations
MeanBV_Exotic <- CalcMeanBV(RefExoticPop)
MeanDD_Exotic <- CalcMeanDD(RefExoticPop)

###----- Check Fst between local and exotic populations at Generation 20
Fst$Fst20 <- calcFst(LocalBreed20, ExoticBreed20, c(LocalBreed20, ExoticBreed20)) 

### -----Export phenotypic values, breeding values, dominance deviations and
  #      population parameters for pure generations  ----
ExportData <- c("Summary_LocalBreed", "MeanBV_Local", "MeanDD_Local",
                "Summary_ExoticBreed", "MeanBV_Exotic","MeanDD_Exotic", 
                "Fst", "HetFounders", "HetLocalFounders")
for (i in ExportData) {
  dat <- get(i)
  write.table(dat, file = paste0(cwd,"/","Results/",i, "_", Strategy, ".txt" ),
              append =T, row.names = F, col.names = F )
}
