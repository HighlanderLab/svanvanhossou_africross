
# Villages and farms

# ---- Create small farms ----

# List of farms
Farms <- vector("list", nFarms)
names(Farms) <- paste0("Farm", c(1:nFarms))

# Sample farm size
repeat {
  cowSizes <- sample(nMinCows_f:nMaxCows_f, size = nFarms, replace = TRUE)
  print(sum(cowSizes))
  if (sum(cowSizes) > 4000 & sum(cowSizes) < 5000) { # Optional: ensure that most of the simulated local 
    break                                            # cows from generation 20 are further used.
  }
}

# Select cows from the local breeds (Generation 20)
Localcows <- selectInd(LocalBreed20, nInd = sum(cowSizes), trait = "TickCount_local",
                       use = "pheno", sex = "F")
CowOrder <- sample(Localcows@id, size = sum(cowSizes), replace = FALSE) # randomly sample CowIDs

#  Randomly assign cows to farms
for (i in (1:length(Farms))) { # For each Farm
  # Match randomised CowID with cow population, subset full cow population into Farm Pop & store Farm Pop
  Farms[[i]] <- Localcows[match(CowOrder[c(1:cowSizes[i])], Localcows@id)]
  CowOrder <- CowOrder[-c(1:cowSizes[i])] # Remove sampled CowIDs
}

# ---- Create villages ----

# Create list of villages
Villages <- vector("list", nVillages)
names(Villages) <- paste0("Village", c(1:nVillages))

# Randomly assign farms to villages
FarmOrder <- sample( 1: nFarms, size = nFarms, replace = FALSE)
start <- seq(1,nFarms, by=nFarms/nVillages)
stop <- seq(nFarms/nVillages, nFarms, by=nFarms/nVillages)

for (each in (1:nVillages)) { # For each village
  # Villages[[each]] <- Farms[start[each]:stop[each]]
  Villages[[each]] <- Farms[FarmOrder[start[each]:stop[each]]]
}

# Assignment of bulls to the villages
# Exotic Breed
ExoticBulls20_v <- AssignBull_v(ExoticBulls_Nucleus, nVillages, nBull_v)
# Local Breed
LocalBulls20_v <- AssignBull_v(LocalBulls_Nucleus, nVillages, nBull_v)

# List of R objects before crossbreeding (used to reset the R environment after each crossbreeding scenario)
InitObjects <- ls()
InitObjects <- c(InitObjects, "InitObjects")
