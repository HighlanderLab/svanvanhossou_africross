
# F1 (Terminal)
Strategy <- "F1"

cat("**** Starting with ", Strategy, " ****\n")

# ---- Create objects to store farms and villages populations ----

# Create objects to store populations at village level
LocalOffsprings_v <- vector("list", nVillages)
names(LocalOffsprings_v) <- paste0("Village", c(1:nVillages))

HybridOffsprings_v <- vector("list", nVillages)
names(HybridOffsprings_v) <- paste0("Village", c(1:nVillages))

LocalCows_v <- vector("list", nVillages)
names(LocalCows_v) <- paste0("Village", c(1:nVillages))

LocalBulls_v <- vector("list", nVillages)
names(LocalBulls_v) <- paste0("Village", c(1:nVillages))

HybridCows_v <- vector("list", nVillages)
names(HybridCows_v) <- paste0("Village", c(1:nVillages))

HybridBulls_v <- vector("list", nVillages)
names(HybridBulls_v) <- paste0("Village", c(1:nVillages))

LocalRefPop_v <- vector("list", nVillages)
names(LocalRefPop_v) <- paste0("Village", c(1:nVillages))

HybridRefPop_v <- vector("list", nVillages)
names(HybridRefPop_v) <- paste0("Village", c(1:nVillages))

LocalCandidates_v <- vector("list", nVillages)
names(LocalCandidates_v) <- paste0("Village", c(1:nVillages))

Candidates_v <- vector("list", nVillages)
names(Candidates_v) <- paste0("Village", c(1:nVillages))

# Create object to store populations at farm level
LocalOffsprings_f <- Villages
LocalCows_f <- Villages
HybridCows_f <- Villages
HybridOffsprings_f <- Villages
HybridRefPop_f <- Villages
LocalRefPop_f <- Villages
Candidates_f  <- Villages
LocalCandidates_f  <- Villages

# ---- Crossbreeding for Generation 21 ----

Gen <- 21
cat("**** Currently at Generation ", Gen, "****\n")

# ---- Local and Hybrids ----
for (v in 1:nVillages) {
  # Create bull index to randomly assigned one bull to each farm within the Village
  Bindex <-  sample(rep(1:nBull_v, nFarms_v/nBull_v), nFarms_v, replace = FALSE)

  for (f in 1:nFarms_v) {
    cat("Working on Farm ", f, " in Village ", v, "\n")
    # Crossbreeeding
    HybridOffsprings_f[[v]][[f]] <- randCross2(females = LocalCows_f[[v]][[f]], males = ExoticBulls20_v[[v]][Bindex[f]],
                                               nCrosses = nInd(LocalCows_f[[v]][[f]]))
    HybridOffsprings_f[[v]][[f]] <- setPheno(HybridOffsprings_f[[v]][[f]], h2 = h2)
    HybridOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(HybridOffsprings_f[[v]][[f]])))
    HybridRefPop_f[[v]][[f]]<-  HybridOffsprings_f[[v]][[f]]
    # Local breed
    LocalOffsprings_f[[v]][[f]] <- randCross2(females = LocalCows_f[[v]][[f]],
                                              males = LocalBulls20_v[[v]][Bindex[f]],
                                              nCrosses = nInd(LocalCows_f[[v]][[f]]))
    LocalOffsprings_f[[v]][[f]] <- setPheno(LocalOffsprings_f[[v]][[f]], h2 =  h2)
    LocalOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(LocalOffsprings_f[[v]][[f]])))

    # Select local cows at farm level
    LocalRefPop_f[[v]][[f]]<- c(LocalRefPop_f[[v]][[f]], LocalOffsprings_f[[v]][[f]])
    LocalCandidates_f[[v]][[f]] <- LocalRefPop_f[[v]][[f]][LocalRefPop_f[[v]][[f]]@misc$gen >= Gen - 4]
    LocalCows_f[[v]][[f]] <- selectInd(LocalCandidates_f[[v]][[f]], nInd(Villages[[v]][[f]]), trait = "TickCount_local",
                                       use = "pheno", sex = "F")
  }

  # Merge populations at Village level
  LocalOffsprings_v[[v]] <- mergePops(LocalOffsprings_f[[v]])
  LocalCows_v[[v]] <- mergePops(LocalCows_f[[v]])
  LocalRefPop_v [[v]] <- mergePops(LocalRefPop_f[[v]])
  # Hybrid
  HybridOffsprings_v[[v]] <- mergePops(HybridOffsprings_f[[v]])
  HybridRefPop_v [[v]] <- mergePops(HybridRefPop_f[[v]])

  # Select Local Bulls at Village level
  LocalCandidates_v[[v]] <- LocalRefPop_v[[v]][LocalRefPop_v[[v]]@misc$gen >= Gen - 1]
  LocalBulls_v[[v]] <-selectInd(LocalCandidates_v[[v]], nInd = nBull_v, sex = "M",
                                trait = "TickCount_local", use = "pheno")
}

# Merge overall population
# Hybrid
HybridOffsprings <- mergePops(HybridOffsprings_v)

# Calculate Inbreeding coeficient and heterosis
InbredingCoef <- CompCoefInb(pop = HybridOffsprings)
Heterosis <- calcHeterosis(Localcows, ExoticBulls_Nucleus, HybridOffsprings)
Heterosis_G <- calcHeterosis_G(Localcows, ExoticBulls_Nucleus, HybridOffsprings)

write.table(Heterosis, file = paste0(cwd, "/Results/Heterosis", ".txt"),
            append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(Heterosis_G, file = paste0(cwd, "/Results/Heterosis_G", ".txt"),
            append = TRUE, row.names = FALSE, col.names = FALSE)

# Local
LocalOffsprings <- mergePops(LocalOffsprings_v)
LocalBulls <- mergePops(LocalBulls_v)
LocalCows <- mergePops(LocalCows_v)

# ---- Exotic Nucleus herd  ----

ExoticNucleus = randCross2(females = ExoticCows_Nucleus, males = ExoticBulls_Nucleus, nCrosses = 2000)
ExoticNucleus <- setPheno(ExoticNucleus, h2 = h2)
ExoticNucleus@misc <- list(gen = rep(Gen, times = nInd(ExoticNucleus)))
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
Offs <-c("HybridOffsprings", "LocalOffsprings", "LocalBulls", "LocalCows",
         "ExoticNucleus", "ExoticBullsNucleus", "ExoticCowsNucleus")

for (i in Offs) {
  SummaryAll <- recordSummary(pop = get(i), year = Gen)
  assign(paste0("Summary_", i), SummaryAll)
}

# ---- Crossbreeding for Generation 22-40 ----

for (Gen in 22:40) {
  cat("**** Currently at Generation ", Gen, "****\n")

  # ---- Local and Hybrids ----

  for (v in 1:nVillages) {
    # Create bull index to randomly assigned
    Bindex <-  sample(rep(1:nBull_v, nFarms_v/nBull_v), nFarms_v, replace = FALSE)

    for (f in 1:nFarms_v) {
       cat("Working on Farm ", f, " in Village ", v, "\n")
      # Crossbreeeding
      HybridOffsprings_f[[v]][[f]] <- randCross2(females = LocalCows_f[[v]][[f]], males = ExoticBulls_v[[v]][Bindex[f]],
                                                 nCrosses = nInd(LocalCows_f[[v]][[f]]))
      HybridOffsprings_f[[v]][[f]] <- setPheno(HybridOffsprings_f[[v]][[f]], h2 = h2)
      HybridOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(HybridOffsprings_f[[v]][[f]])))
      HybridRefPop_f[[v]][[f]]<- c(HybridRefPop_f[[v]][[f]], HybridOffsprings_f[[v]][[f]])

      # Local breed
      LocalOffsprings_f[[v]][[f]] <- randCross2(females = LocalCows_f[[v]][[f]], males = LocalBulls_v[[v]][Bindex[f]],
                                                nCrosses = nInd(LocalCows_f[[v]][[f]]))
      LocalOffsprings_f[[v]][[f]] <- setPheno(LocalOffsprings_f[[v]][[f]], h2 = h2)
      LocalOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(LocalOffsprings_f[[v]][[f]])))

      # Select Local cows at farm level
      LocalRefPop_f[[v]][[f]]<- c(LocalRefPop_f[[v]][[f]], LocalOffsprings_f[[v]][[f]])
      Candidates_f[[v]][[f]] <- LocalRefPop_f[[v]][[f]][LocalRefPop_f[[v]][[f]]@misc$gen >= Gen - 4]
      LocalCows_f[[v]][[f]] <- selectInd(Candidates_f[[v]][[f]], nInd(Villages[[v]][[f]]),
                                         trait = "TickCount_local", use = "pheno", sex = "F")
    }

    # Merge populations at Village level
    LocalOffsprings_v[[v]] <- mergePops(LocalOffsprings_f[[v]])
    LocalCows_v[[v]] <- mergePops(LocalCows_f[[v]])
    LocalRefPop_v [[v]] <- mergePops(LocalRefPop_f[[v]])

    # Hybrid
    HybridOffsprings_v[[v]] <- mergePops(HybridOffsprings_f[[v]])
    HybridRefPop_v[[v]] <-  mergePops(HybridRefPop_f[[v]])

    # Select Bulls at Village level
    # Local
    LocalCandidates_v[[v]] <- LocalRefPop_v[[v]][LocalRefPop_v[[v]]@misc$gen >= Gen - 1]
    LocalBulls_v[[v]] <-selectInd(LocalCandidates_v[[v]], nInd = nBull_v, sex = "M",
                                  trait = "TickCount_local",  use = "pheno")
  }

  # Merge overall population
  # Hybrid
  HybridOffsprings <- mergePops(HybridOffsprings_v)
  Heterosis <- calcHeterosis(Localcows, mergePops(ExoticBulls_v), HybridOffsprings)
  Heterosis_G <- calcHeterosis_G(Localcows, mergePops(ExoticBulls_v), HybridOffsprings)

  # Local
  LocalOffsprings <- mergePops(LocalOffsprings_v)
  LocalBulls <- mergePops(LocalBulls_v)
  LocalCows <- mergePops(LocalCows_v)

  #---- Exotic nucleus herd -----

  ExoticNucleus = randCross2(females = ExoticCowsNucleus, males = ExoticBullsNucleus, nCrosses = 2000)
  ExoticNucleus <- setPheno(ExoticNucleus, h2 = h2)
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

  # Calculate Inbreeding coeficient
  InbredingCoef <- CompCoefInb(InbredingCoef, pop = HybridOffsprings)

  # Store the outputs
  for (i in Offs) {
    SummaryAll <- recordSummary(data = get(paste0("Summary_", i)), pop = get(i), year = Gen)
    assign(paste0("Summary_", i), SummaryAll)
  }

  write.table(Heterosis, file = paste0(cwd, "/Results/Heterosis", ".txt"),
              append = TRUE, row.names = FALSE, col.names = FALSE)
  write.table(Heterosis_G, file = paste0(cwd, "/Results/Heterosis_G", ".txt"),
              append = TRUE, row.names = FALSE, col.names = FALSE)
}

# Calculate and export average Breeding values and Dominance deviation
MeanBV_Hybrids <- CalcMeanBV(mergePops(HybridRefPop_v))
MeanDD_Hybrids <- CalcMeanDD(mergePops(HybridRefPop_v))

write.table(MeanBV_Hybrids, file = paste0(cwd, "/Results/MeanBV_Hybrids", ".txt"),
            append = TRUE, quote = FALSE, sep = "\t",  row.names = FALSE , col.names = FALSE)
write.table(MeanDD_Hybrids, file = paste0(cwd, "/Results/MeanDD_Hybrids", ".txt"),
            append = TRUE, quote = FALSE, sep = "\t",  row.names = FALSE , col.names = FALSE)

# ----- Export the Summary outputs ----

for (i in Offs) {
  dat <- get(paste0("Summary_", i))
  write.table(dat, file = paste0(cwd, "/Results/Summary_", i, ".txt"),
              append = TRUE, row.names = FALSE, col.names = FALSE)
}

write.table(InbredingCoef, file = paste0(cwd, "/Results/InbredingCoefs", ".txt"),
            append = TRUE, row.names = FALSE, col.names = FALSE)

 # Clear environment
keep(list = InitObjects, sure = TRUE)
