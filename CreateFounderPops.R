###---------------------------------------------------------------------------------
#                         Simulation parameters 
###---------------------------------------------------------------------------------

###-------Global parameters to simulate the founders genome ------
NFounders <- 5000
nChr = 30
nSNP <- 1400
nQTL <- 300
nSplit = 20000 

###----- Genetic parameters for two polygenic traits ------
            #c(BodyWeight_local, TickCount_local, BodyWeight_exotic, TickCount_exotic)

 #Parameters to simulate additive effects
h2 <- c(0.3, 0.1, 0.3, 0.1)       
PhenoMean <- c(325, 0.5, 450, 1.5)
PhenoVar <- c(1300, 0.1, 625, 0.2)
AdditVar <- PhenoVar*h2 
 
 #Trait correlations
CorA <-0.2  #genetic correlation between BodyWeight and TickCount in the same breed
CorB<- 0.6  #genetic correlation between the same trait (e.g. BodyWeight) in the two breeds

TraitCor <- matrix(c(1, CorA, CorB, CorA/2,
                     CorA, 1, CorA/2, CorB,
                     CorB, CorA/2, 1, CorA,
                     CorA/2, CorB, CorA, 1
                     ),
                    nrow = 4, ncol = 4)

##Parameters to simulate dominance degree (effects) 
 #the expected proportion of dominance variance (VD) to phenotype variance (VP) is: 
 #0.1 for Body weight (Bolormaa et al., 2015) and 0.04 for Tickcount (Schneider et al., 2023)
DomMean <- c(0.5, 0.8, 0.5, 0.8)  
DomVar  <- c(0.4,0.2, 0.4, 0.2)


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

ExoticFounders = Founders[2501:5000]
ExoticFounders@sex <- sample(rep(c("F","M"), c(2000, 500)), 2500, replace = F)

###----- Update simulation parameter to systematically generate animal sex
SP$resetPed()
SP$setSexes("yes_sys")

###----- Evaluate genetic distance between local and exotic founders -----
Fst <- calcFst(LocalFounders, ExoticFounders, Founders) 
HetFounders <- calcHet(Founders)
HetLocalFounders <- calcHet(LocalFounders)
HetExoticFounders <-calcHet(ExoticFounders)

