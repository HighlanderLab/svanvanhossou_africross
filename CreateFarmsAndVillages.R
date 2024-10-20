# ---- Create small farms ----

# List of farms
Farms <- vector("list", nFarms)
names(Farms) <- paste0("Farm", c(1:nFarms))

# Sample farm size
repeat {
  cowSizes <- sample(8:40, size = nFarms, replace = TRUE)
  print(sum(cowSizes))
  if (sum(cowSizes) > 4000 & sum(cowSizes) < 5000) {
    break
  }
}

# Select cows from the local breeds (Generation 20)
Localcows <- selectInd(LocalBreed20, nInd = sum(cowSizes), trait = "TickCount_local",
                       use = "pheno", sex = "F")
CowOrder <- sample(Localcows@id, size = sum(cowSizes), replace = FALSE) # randomly sample CowIDs

#  Randomly assign cows to farms
for (i in (1:length(Farms))) { # For each Farm
  # Match randomised CowID with CowPopulation, Subset full cow population into Farm Pop & store Farm Pop
  Farms[[i]] <- Localcows[match(CowOrder[c(1:cowSizes[i])], Localcows@id)]
  CowOrder <- CowOrder[-c(1:cowSizes[i])] # Remove sampled CowIDs
}

# ---- Create Villages ----

# create list of villages
Villages <- vector("list", nVillages)
names(Villages) <- paste0("Village", c(1:nVillages))

# Randomly assign farms to Villages
FarmOrder <- sample( 1: nFarms, size = nFarms, replace = FALSE)
start <- seq(1,nFarms, by=nFarms/nVillages)
stop <- seq(nFarms/nVillages, nFarms, by=nFarms/nVillages)

for (each in (1:nVillages)) { # For each Village
  # Villages[[each]] <- Farms[start[each]:stop[each]]
  Villages[[each]] <- Farms[FarmOrder[start[each]:stop[each]]]
}

# Assignment of Bulls to the Villages
# Exotic Breed
ExoticBulls20_v <- AssignBull_v(ExoticBulls_Nucleus, nVillages, nBull_v)
# Local Breed
LocalBulls20_v <- AssignBull_v(LocalBulls_Nucleus, nVillages, nBull_v)

# List of R objects before Crossbreeding
InitObjects <- ls()
InitObjects <- c(InitObjects, "InitObjects")
