###---------------------------------------------------------------------------------
#               Simulation of cattle genome & founder populations 
###---------------------------------------------------------------------------------

### -----Simulate Founders genome -----
FounderGenomes <- runMacs(
  nInd = NFounders,
  nChr = nChr,
  segSites = nSNP + nQTL,
  inbred = FALSE,
  split  = nSplit,
  species = "CATTLE"
)
#save(FounderGenomes, file = "FounderGenomes.RData")

###----- Set simulation parameters to model the traits
#         with additive and dominance architecture -----
repeat {
  SP = SimParam$new(FounderGenomes)
  SP$addSnpChip(nSnpPerChr=nSNP)
  SP$addTraitAD(nQTL,
                mean= PhenoMean,
                var=AdditVar,
                corA = TraitCor,
                meanDD = DomMean, 
                varDD =  DomVar, 
                gamma = FALSE,
                name = c("BodyWeight_local", "TickCount_local", 
                         "BodyWeight_exotic", "TickCount_exotic"))
  
  ###----- Create founder populations -----
  #Generate initial founder population
  Founders = newPop(FounderGenomes)
  Founders = setMisc(x = Founders, node = "yearOfBirth", value = 0)
  
  #Split the initial founder into local and exotic founders
  LocalFounders = Founders[1:2500] 
  LocalFounders@sex <- sample(rep(c("F","M"), c(2000, 500)), 2500, replace = F)
  LocalFounders = setPheno(pop = LocalFounders, h2 = h2)
  
  ExoticFounders = Founders[2501:5000]
  ExoticFounders@sex <- sample(rep(c("F","M"), c(2000, 500)), 2500, replace = F)
  ExoticFounders = setPheno(pop = ExoticFounders, h2 = h2)

  #Ensure that the expected heritabilities are obtained in the founder populations
  h2_local <- diag(varA(LocalFounders)/varP(LocalFounders))
  h2_exotic <- diag(varA(ExoticFounders)/varP(ExoticFounders))
  print(h2_local)
  print(h2_exotic)
  if (h2_local[1] > 0.27 & h2_local[1] < 0.33 & 
      h2_local[2] > 0.09 & h2_local[2] < 0.11 &
      h2_exotic[1] > 0.27 & h2_exotic[1] < 0.33 &
      h2_exotic[2] > 0.09 & h2_exotic[2] < 0.11 &
      h2_exotic[3] > 0.27 & h2_exotic[3] < 0.33 &
      h2_exotic[4] > 0.09 & h2_exotic[4] < 0.11){
    break
  }
}
cat("Dominance heritability \n")
print(diag(varD(LocalFounders)/varP(LocalFounders)))
print(diag(varD(LocalFounders)/varP(LocalFounders)))

###----- Update simulation parameter to systematically generate animal sex
SP$resetPed()
SP$setSexes("yes_sys")

###----- Evaluate genetic distance between local and exotic founders -----
Fst <- calcFst(LocalFounders, ExoticFounders, Founders) 
HetFounders <- calcHet(Founders)
HetLocalFounders <- calcHet(LocalFounders)
HetExoticFounders <-calcHet(ExoticFounders)
