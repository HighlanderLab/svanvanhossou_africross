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
#c("BodyWeight_local", "TickCount_local", "BodyWeight_exotic", "TickCount_exotic")

#Parameters to simulate additive effects
h2 <- c(0.3, 0.1, 0.3, 0.1)
PhenoMean <- c(325, -1.0, 450, -1.5)
PhenoVar <- c(1300, 0.2, 625, 0.2)
AdditVar <- PhenoVar*(h2) 

# Trait correlations
##genetic correlation (rg)  between BodyWeight and TickCount in the same breed. Different rg were tested.
 CorA <--0.4  
 #CorA <- -0.2
 #CorA <- 0
 #CorA <- 0.2
 #CorA <- 0.4

##genetic correlation between the same trait (e.g. BodyWeight) in the two breeds (as environmental correlation). Different GxE were tested
 CorE <- 0.6  
 #CorE <- 0.4 
 #CorE <- 0.8 (considered for absence of GxE effects)

TraitCor <- matrix(c(1, CorA, CorE, CorA*CorE,
                     CorA, 1, CorA*CorE, CorE,
                     CorE, CorA*CorE, 1, CorA,
                     CorA*CorE, CorE, CorA, 1),
                   nrow = 4, ncol = 4)

## Parameters to simulate dominance degree (effects) 
 # the expected proportion of dominance variance (VD) to phenotype variance (VP) is: 
 # 0.1 for Body weight and 0.04 for Tickcount 
DomMean <- c(0.18, 0.08, 0.18, 0.08)  
DomVar  <- c(1, 1.3, 1, 1.3)

###---- Parameters  to simulate villages and farms----
nVillages <-10
nFarms <- 200
nBull_v <-5  #Number of selected bulls per village. Artificial insemination is assumed.
nFarms_v <- nFarms/nVillages

## Trait index for the selection of hybrid animals
 TraitIndex <- c(1, 80, 0,0)   # corresponding to 50% weight for each trait. The weights were estimated based on the phenotypic variance of the two traits
 #TraitIndex <- c(1, 30, 0,0)  # corresponding to 30% weight for tick count and 70 % weight for body weight
 #TraitIndex <- c(1, 10, 0,0)  # corresponding to 10% weight for tick count and 90 % weight for body weight


