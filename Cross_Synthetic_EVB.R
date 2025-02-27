
# Synthetic "exchanged-village bull"
Strategy <- "Synthetic_EVB"

cat("**** Starting with ", Strategy, " ****\n")

# ---- Create objects to store farms and villages populations ----

# Create objects to store populations at village level
HybridOffsprings_v <- vector("list", nVillages)
names(HybridOffsprings_v) <- paste0("Village", 1:nVillages)

HybridCows_v <- vector("list", nVillages)
names(HybridCows_v) <- paste0("Village", 1:nVillages)

HybridBulls_v <- vector("list", nVillages)
names(HybridBulls_v) <- paste0("Village", 1:nVillages)

HybridRefPop_v <- vector("list", nVillages)
names(HybridRefPop_v) <- paste0("Village", 1:nVillages)

Candidates_v <- vector("list", nVillages)
names(Candidates_v) <- paste0("Village", 1:nVillages)

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
  #create bull index to randomly assigned one bull to each farm within the Village
  Bindex <- sample(1:nBull_v, nFarms_v, replace = TRUE)

  for (f in 1:nFarms_v) {
    cat("Working on Farm ", f, " in Village ", v, "\n")
    HybridOffsprings_f[[v]][[f]] <- randCross2(females = LocalCows_f[[v]][[f]], males = ExoticBulls20_v[[v]][Bindex[f]],
                                               nCrosses = nInd(LocalCows_f[[v]][[f]]))
    HybridOffsprings_f[[v]][[f]] <- setPheno(HybridOffsprings_f[[v]][[f]], h2 = h2)
    HybridOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(HybridOffsprings_f[[v]][[f]])))
    HybridRefPop_f[[v]][[f]]<- HybridOffsprings_f[[v]][[f]]

    # Select hybrid cows
    HybridCows_f[[v]][[f]] <- HybridOffsprings_f[[v]][[f]][HybridOffsprings_f[[v]][[f]]@sex == "F"]
  }

  # Merge populations at Village level
  HybridOffsprings_v[[v]] <- mergePops(HybridOffsprings_f[[v]])
  HybridCows_v[[v]] <- mergePops(HybridCows_f[[v]])
  HybridRefPop_v [[v]] <- mergePops(HybridRefPop_f[[v]])

  # Select Bulls at Village level
  HybridBulls_v[[v]] <- selectInd(HybridOffsprings_v[[v]], nInd = nBull_v, trait = selIndex, b = TraitIndex,  use = "pheno", sex = "M")
}

# Merge overall population
HybridOffsprings <- mergePops(HybridOffsprings_v)
HybridCows <- mergePops(HybridCows_v)
HybridBulls <- mergePops(HybridBulls_v)

# Calculate Inbreeding coeficient and heterosis
InbredingCoef <- CompCoefInb(pop = HybridOffsprings)
Heterosis <- calcHeterosis(Localcows, ExoticBulls_Nucleus, HybridOffsprings)
Heterosis_G <- calcHeterosis_G(Localcows, ExoticBulls_Nucleus, HybridOffsprings)

write.table(Heterosis, file = paste0(cwd, "/Results/Heterosis", ".txt"),
            append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(Heterosis_G, file = paste0(cwd, "/Results/Heterosis_G", ".txt"),
            append = TRUE, row.names = FALSE, col.names = FALSE)

# Store the output
Offs <- c("HybridOffsprings", "HybridBulls", "HybridCows")

for (i in Offs) {
  SummaryAll <- recordSummary(pop = get(i), year = Gen)
  assign(paste0("Summary_", i), SummaryAll)
}

# ---- Crossbreeding for Generation 22-40 ----

for (Gen in 22:40) {
  cat("**** Currently at Generation ", Gen, "****\n")

  # Randomly sample villages where bulls will be sent
  V <- 1:nVillages

  repeat {
    Vindex <- sample(1:nVillages, nVillages, replace = FALSE)
    print(Vindex) #  the index that determines the allocation of bulls to the villages. 
    checks <-  Vindex[V] == V # Check whether village indexes are different from the initial village IDs
    if (all(checks == FALSE)) { # (ensure the exchange of bulls between villages)
      break
    }
  }

  for (v in 1:nVillages) {
    # Create bull index to randomly assigned one bull to each farm within the Village
    Bindex <- sample(1:nBull_v, nFarms_v, replace = TRUE)

    for (f in 1:nFarms_v) {
      cat("Working on Farm ", f, " in Village ", v, "\n")
      HybridOffsprings_f[[v]][[f]] <- randCross2(females = HybridCows_f[[v]][[f]], males = HybridBulls_v[[Vindex[v]]][Bindex[f]],
                                                 nCrosses = nInd(HybridCows_f[[v]][[f]]))
      HybridOffsprings_f[[v]][[f]] <- setPheno(HybridOffsprings_f[[v]][[f]], h2 =  h2)
      HybridOffsprings_f[[v]][[f]]@misc <- list(gen = rep(Gen, times = nInd(HybridOffsprings_f[[v]][[f]])))
      HybridRefPop_f[[v]][[f]] <- c(HybridRefPop_f[[v]][[f]], HybridOffsprings_f[[v]][[f]])

      #Select hybrid cows
      Candidates_f[[v]][[f]] <- HybridRefPop_f[[v]][[f]][HybridRefPop_f[[v]][[f]]@misc$gen >= (Gen - 4)]
      HybridCows_f[[v]][[f]] <- selectInd(Candidates_f[[v]][[f]], nInd(Villages[[v]][[f]]),
                                          trait = selIndex, b = TraitIndex, use = "pheno", sex = "F")
    }

    # Merge populations at Village level
    HybridCows_v[[v]] <- mergePops(HybridCows_f[[v]])
    HybridOffsprings_v[[v]] <- mergePops(HybridOffsprings_f[[v]])
    HybridRefPop_v[[v]] <- mergePops(HybridRefPop_f[[v]])

    # Select Bulls at Village level
    Candidates_v[[v]] <- HybridRefPop_v[[v]][HybridRefPop_v[[v]]@misc$gen >= (Gen - 1)]
    HybridBulls_v[[v]] <- selectInd(Candidates_v[[v]], nBull_v, trait = selIndex, b = TraitIndex, use = "pheno", sex = "M")
  }

  # Merge overall population
  HybridOffsprings <- mergePops(HybridOffsprings_v)
  HybridBulls <- mergePops(HybridBulls_v)
  HybridCows <- mergePops(HybridCows_v)

  # Calculate Heterosis
  Heterosis <- calcHeterosis(HybridCows, HybridBulls, HybridOffsprings)
  Heterosis_G <- calcHeterosis_G(HybridCows, HybridBulls, HybridOffsprings)

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
            append = TRUE, quote = FALSE, sep = "\t",  row.names = FALSE, col.names = FALSE)
write.table(MeanDD_Hybrids, file = paste0(cwd, "/Results/MeanDD_Hybrids", ".txt"),
           append = TRUE, quote = FALSE, sep = "\t",  row.names = FALSE, col.names = FALSE)

# ----- Export the Summary outputs

for (i in Offs) {
  dat <- get(paste0("Summary_", i))
  write.table(dat, file = paste0(cwd, "/Results/Summary_", i, ".txt"),
              append = TRUE, row.names = FALSE, col.names = FALSE)
}

write.table(InbredingCoef, file = paste0(cwd, "/Results/InbredingCoefs", ".txt"),
            append = TRUE, row.names = FALSE, col.names = FALSE)

# Clear environment
keep(list = InitObjects, sure = TRUE)
