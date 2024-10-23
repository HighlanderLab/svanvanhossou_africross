
# Rotational
Strategy <- "Rotational"

cat("**** Starting with ", Strategy, " ****\n")

# ---- Create objects to store farms and villages populations ----

HybridOffsprings_v <- vector("list", nVillages)
names(HybridOffsprings_v) <- paste0("Village", c(1:nVillages))

HybridCows_v <- vector("list", nVillages)
names(HybridCows_v) <- paste0("Village", c(1:nVillages))

HybridBulls_v <- vector("list", nVillages)
names(HybridBulls_v) <- paste0("Village", c(1:nVillages))

HybridRefPop_v<- vector("list", nVillages)
names(HybridRefPop_v) <- paste0("Village", c(1:nVillages))

Candidates_v <- vector("list", nVillages)
names(Candidates_v) <- paste0("Village", c(1:nVillages))

# Create objects to store populations at farm level
LocalCows_f <- Villages
HybridCows_f <- Villages
HybridOffsprings_f <- Villages
HybridRefPop_f <- Villages
Candidates_f  <- Villages

# ---- Crossbreeding for Generation 21 ----

Gen <- 21
 cat("**** Currently at Generation ", Gen, "****\n")

for (v in 1:nVillages) {
 # Create bull index to randomly assigned one bull to each farm within the Village
 Bindex <-  sample(rep(1:nBull_v, nFarms_v/nBull_v), nFarms_v, replace = F)
	
  for (f in 1:nFarms_v) {
    cat("Working on Farm ", f, " in Village ", v, "\n")
    HybridOffsprings_f[[v]][[f]] <- randCross2(females = LocalCows_f[[v]][[f]], males = ExoticBulls20_v[[v]][Bindex[f]],
                                               nCrosses = nInd(LocalCows_f[[v]][[f]]))
    HybridOffsprings_f[[v]][[f]] <- setPheno (HybridOffsprings_f[[v]][[f]], h2 = h2)
    HybridOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(HybridOffsprings_f[[v]][[f]])))
    HybridRefPop_f[[v]][[f]]<-  HybridOffsprings_f[[v]][[f]]
	  
    # Select cows at farm level
    HybridCows_f[[v]][[f]] <- HybridOffsprings_f[[v]][[f]][HybridOffsprings_f[[v]][[f]]@sex == "F"]
  }

  # Merge populations at Village level
  HybridOffsprings_v[[v]] <- mergePops(HybridOffsprings_f[[v]])
  HybridCows_v[[v]] <- mergePops(HybridCows_f[[v]])
  HybridRefPop_v [[v]] <- mergePops(HybridRefPop_f[[v]])
 }

# Merge overall population
  HybridOffsprings <- mergePops(HybridOffsprings_v)
  HybridCows <- mergePops(HybridCows_v)

# Calculate Inbreeding coeficient and heterosis
InbredingCoef <- CompCoefInb(pop = HybridOffsprings)
Heterosis <- calcHeterosis(Localcows, ExoticBulls_Nucleus, HybridOffsprings)
Heterosis_G <- calcHeterosis_G(Localcows, ExoticBulls_Nucleus, HybridOffsprings)

write.table(Heterosis, file = paste0(cwd, "/Results/Heterosis", ".txt"),
            append = T, row.names = F, col.names = F)
write.table(Heterosis_G, file = paste0(cwd, "/Results/Heterosis_G", ".txt"),
            append = T, row.names = F, col.names = F)

 # ---- Local Nucleus herd ----
  LocalNucleus = randCross2(females = LocalCows_Nucleus, males = LocalBulls_Nucleus, nCrosses = 2000)
  LocalNucleus <- setPheno (LocalNucleus, h2 = h2)
  LocalNucleus@misc <- list(gen = rep(Gen, times = nInd(LocalNucleus)))
  LocalNucleusRefPop <- c(LocalBulls_Nucleus, LocalCows_Nucleus, LocalNucleus)
  Candidates <- LocalNucleusRefPop[LocalNucleusRefPop@misc$gen >= Gen - 4]
  LocalBullsNucleus <- selectInd(Candidates[Candidates@misc$gen >= Gen - 1],  sex = "M",
                                 nInd = nBull_v*nVillages, trait = "TickCount_local", use = "pheno")
  LocalBulls_v <- AssignBull_v(ExoticBulls, nVillages, nBull_v)
  LocalCowsNucleus <- selectInd(Candidates, nInd = 2000, sex = "F",
                                trait = "TickCount_local", use = "pheno")

  # ---- Exotic Nucleus herd -----
  ExoticNucleus = randCross2(females = ExoticCows_Nucleus, males = ExoticBulls_Nucleus, nCrosses = 2000)
  ExoticNucleus <- setPheno (ExoticNucleus, h2 = h2)
  ExoticNucleus <- list(gen = rep(Gen, times = nInd(ExoticNucleus)))
  ExoticNucleusRefPop <- c(RefExoticPop, ExoticNucleus)
  Candidates <- ExoticNucleusRefPop[ExoticNucleusRefPop@misc$gen >= Gen - 4]

  # Estimate EBV for the reference population (the last 5 generations)
  ans = RRBLUP(Candidates, traits = "BodyWeight_exotic")
  Candidates <- setEBV(Candidates, ans)
  ExoticBullsNucleus <- selectInd(Candidates[Candidates@misc$gen >= Gen - 1], sex = "M",
                                  nInd = nBull_v*nVillages, trait = 1, use = "ebv")
  ExoticBulls_v <- AssignBull_v(ExoticBullsNucleus, nVillages, nBull_v)
  ExoticCowsNucleus <- selectInd(Candidates, nInd = 2000, trait = 1, use = "ebv", sex = "F")

# Store the outputs
Offs <-c("HybridOffsprings", "HybridCows", "LocalNucleus", "LocalCowsNucleus", "LocalBullsNucleus",
         "ExoticNucleus", "ExoticCowsNucleus", "ExoticBullsNucleus")

for (i in Offs) {
  SummaryAll <- recordSummary(pop = get(i), year = Gen)
  assign(paste0("Summary_", i), SummaryAll)
}

# ---- Crossbreeding for Generation 22-40 ----

for (Gen in 22:40) {
  cat("**** Currently at Generation ", Gen, "****\n")

   # Define Bulls for the rotational crossbreeding
  if ((Gen %% 2) == 0)  {
    Bulls_v <- LocalBulls_v
  } else {
    Bulls_v <- ExoticBulls_v
  }

  for (v in 1:nVillages) {
    # Create bull index to randomly assigned
    Bindex <-  sample(rep(1:nBull_v, nFarms_v/nBull_v), nFarms_v, replace = F)

    for (f in 1:nFarms_v) {
      cat("Working on Farm ", f, " in Village ", v, "\n")
      HybridOffsprings_f[[v]][[f]] <- randCross2(females = HybridCows_f[[v]][[f]], males = Bulls_v[[v]][Bindex[f]],
                                                 nCrosses = nInd(HybridCows_f[[v]][[f]]))
      HybridOffsprings_f[[v]][[f]] <- setPheno (HybridOffsprings_f[[v]][[f]], h2 = h2)
      HybridOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(HybridOffsprings_f[[v]][[f]])))
      HybridRefPop_f[[v]][[f]]<- c(HybridRefPop_f[[v]][[f]], HybridOffsprings_f[[v]][[f]])
	    
	  # Select hybrid cows
      Candidates_f[[v]][[f]] <- HybridRefPop_f[[v]][[f]][HybridRefPop_f[[v]][[f]]@misc$gen >= Gen - 4]
      HybridCows_f[[v]][[f]] <- selectInd(Candidates_f[[v]][[f]], nInd(Villages[[v]][[f]]),
                                          trait = selIndex, b = TraitIndex, use = "pheno", sex = "F")
       }

    # Merge populations at Village level
    HybridCows_v[[v]] <- mergePops(HybridCows_f[[v]])
    HybridOffsprings_v[[v]] <- mergePops(HybridOffsprings_f[[v]])
    HybridRefPop_v[[v]] <-  mergePops(HybridRefPop_f[[v]])
     }

  # Merge overall population
  HybridOffsprings <- mergePops(HybridOffsprings_v)
  Heterosis <- calcHeterosis(HybridCows, mergePops(Bulls_v), HybridOffsprings)
  Heterosis_G <- calcHeterosis_G(HybridCows, mergePops(Bulls_v), HybridOffsprings)
  HybridCows <- mergePops(HybridCows_v)

  # ---- Local Nucleus herd ----
  LocalNucleus = randCross2(females = LocalCowsNucleus, males = LocalBullsNucleus, nCrosses = 2000)
  LocalNucleus <- setPheno (LocalNucleus, h2 = h2)
  LocalNucleus@misc <- list(gen = rep(Gen, times = nInd(LocalNucleus)))
  LocalNucleusRefPop <- c(LocalNucleusRefPop, LocalNucleus)
  Candidates <- LocalNucleusRefPop[LocalNucleusRefPop@misc$gen >= Gen - 4]
  LocalBullsNucleus <- selectInd(Candidates[Candidates@misc$gen >= Gen - 1],  sex = "M",
                                 nInd = nBull_v*nVillages, trait = "TickCount_local", use = "pheno")
  LocalBulls_v <- AssignBull_v(LocalBullsNucleus, nVillages, nBull_v)
  LocalCowsNucleus <- selectInd(Candidates, nInd= 2000, sex = "F",
                                trait = "TickCount_local", use = "pheno")

  # ---- Exotic Nucleus herd  ----
  ExoticNucleus = randCross2(females = ExoticCowsNucleus, males = ExoticBullsNucleus, nCrosses = 2000)
  ExoticNucleus <- setPheno (ExoticNucleus, h2 = h2)
  ExoticNucleus@misc <- list(gen = rep(Gen, times = nInd(ExoticNucleus)))
  ExoticNucleusRefPop <- c(ExoticNucleusRefPop, ExoticNucleus)
  Candidates <- ExoticNucleusRefPop[ExoticNucleusRefPop@misc$gen >= Gen - 4]
	
  # Estimate EBV for the reference population (the last 5 generations)
  ans = RRBLUP(Candidates, traits = "BodyWeight_exotic")
  Candidates <- setEBV(Candidates, ans)
  ExoticBullsNucleus <- selectInd(Candidates[Candidates@misc$gen >= Gen - 1], sex = "M",
                                  nInd = nBull_v*nVillages, trait = 1, use = "ebv")
  ExoticBulls_v <- AssignBull_v(ExoticBullsNucleus, nVillages, nBull_v)
  ExoticCowsNucleus <- selectInd(Candidates, nInd = 2000, trait = 1, use = "ebv", sex = "F")

 # Store the outputs
 InbredingCoef <- CompCoefInb(InbredingCoef, pop = HybridOffsprings)

  for (i in Offs) {
    SummaryAll <- recordSummary(data = get(paste0("Summary_", i)), pop = get(i), year = Gen)
     assign(paste0("Summary_", i), SummaryAll)}
	
 write.table(Heterosis, file = paste0(cwd, "/Results/Heterosis", ".txt"),
            append = T, row.names = F, col.names = F)
 write.table(Heterosis_G, file = paste0(cwd, "/Results/Heterosis_G", ".txt"),
            append = T, row.names = F, col.names = F)
}

# Calculate and export average Breeding values and Dominance deviation
MeanBV_Hybrids <- CalcMeanBV(mergePops(HybridRefPop_v))
MeanDD_Hybrids <- CalcMeanDD(mergePops(HybridRefPop_v))

write.table(MeanBV_Hybrids, file = paste0(cwd, "/Results/MeanBV_Hybrids", ".txt"),
            append = T, quote = F, sep = "\t", row.names = F, col.names = F)
write.table(MeanDD_Hybrids, file = paste0(cwd, "/Results/MeanDD_Hybrids", ".txt"),
            append = T, quote = F, sep = "\t",  row.names = F, col.names = F)

# Export the Summary outputs
for (i in Offs) {
  dat <- get(paste0("Summary_", i))
  write.table(dat, file = paste0(cwd, "/Results/Summary_", i, ".txt"),
              append = T, row.names = F, col.names = F)
}

write.table(InbredingCoef, file = paste0(cwd, "/Results/InbredingCoefs", ".txt"),
            append = T, row.names = F, col.names = F)

 # Clear environment
 keep(list = InitObjects, sure = T)
