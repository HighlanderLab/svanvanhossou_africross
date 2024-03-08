require(AlphaSimR)
###----- Calculates Fst among two populations  -----
calcFst <- function(pop1, pop2, pop) {
  # Pop 1 expected heterozygosity
  M = pullQtlGeno(pop1)
  p1 = colMeans(M)/2
  He_pop1 = mean(2*p1*(1-p1))
  # Pop 2 expected heterozygosity
  M  = pullQtlGeno(pop2)
  p2 = colMeans(M)/2
  He_pop2 = mean(2*p2*(1-p2))
  # Total pop expected heterozygosity
  M  = pullQtlGeno(pop)
  p = colMeans(M)/2
  He_tot = mean(2*p*(1-p))
  # Fst
  Hs = (He_pop1*pop1@nInd+He_pop2*pop2@nInd)/pop@nInd
  return(data.frame("Fst" = (He_tot-Hs)/He_tot))
}

###----- Calculates heterozygosity and inbreeding   -----
calcHet <- function(pop) {
  geno = pullQtlGeno(pop)
  Het = mean(rowMeans(1-abs(geno-1)))
  Inb = 1 - Het
  return(data.frame(Het, Inb))
}

#---- record phenotypic and genetic values for each trait -----
recordSummary <- function(data = NULL, pop, year = NA) {
  ans = genParam(pop, simParam=SP)
  popData = data.frame(Generation   = year,
                       Strategy     = Strategy,
                       MeanGV_BWl     = meanG(pop)["BodyWeight_local"],
                       SdGV_BWl       = sqrt(varG(pop)["BodyWeight_local","BodyWeight_local"]),
                       MeanPheno_BWl  = meanP(pop)["BodyWeight_local"],
                       SdPheno_BWl    = sqrt(varP(pop)["BodyWeight_local","BodyWeight_local"]),
                       MeanGV_TCl     = meanG(pop)["TickCount_local"],
                       SdGV_TCl      = sqrt(varG(pop)["TickCount_local","TickCount_local"]),
                       MeanPheno_TCl = meanP(pop)["TickCount_local"],
                       SdPheno_TCl    = sqrt(varP(pop)["TickCount_local","TickCount_local"]),
                       MeanGV_BWe     = meanG(pop)["BodyWeight_exotic"],
                       SdGV_BWe      = sqrt(varG(pop)["BodyWeight_exotic","BodyWeight_exotic"]),
                       MeanPheno_BWe  = meanP(pop)["BodyWeight_exotic"],
                       SdPheno_BWe   = sqrt(varP(pop)["BodyWeight_exotic","BodyWeight_exotic"]),
                       MeanGV_TCe     = meanG(pop)["TickCount_exotic"],
                       SdGV_TCe       = sqrt(varG(pop)["TickCount_exotic","TickCount_exotic"]),
                       MeanPheno_TCe  = meanP(pop)["TickCount_exotic"],
                       SdPheno_TCe   = sqrt(varP(pop)["TickCount_exotic","TickCount_exotic"]),
                       VarA_BWl      = varA(pop)["BodyWeight_local","BodyWeight_local"],
                       VarA_TCl     = varA(pop)["TickCount_local","TickCount_local"],
                       VarA_BWe      = varA(pop)["BodyWeight_exotic","BodyWeight_exotic"],
                       VarA_TCe      = varA(pop)["TickCount_exotic","TickCount_exotic"] ,
                       h2_BWl      = varA(pop)["BodyWeight_local","BodyWeight_local"]/varP(pop)["BodyWeight_local","BodyWeight_local"],
                       h2_TCl     = varA(pop)["TickCount_local","TickCount_local"]/varP(pop)["TickCount_local","TickCount_local"],
                       h2_BWe      = varA(pop)["BodyWeight_exotic","BodyWeight_exotic"]/varP(pop)["BodyWeight_exotic","BodyWeight_exotic"],
                       h2_TCe      = varA(pop)["TickCount_exotic","TickCount_exotic"]/varP(pop)["TickCount_exotic","TickCount_exotic"]
  )
  # Manage first instance of calling this function, when data is NULL
  if (is.null(data)) {
    ret = popData
  } else {
    ret = rbind(data, popData)
  }
  return(ret)
}

CalcMeanBV <- function(pop){
  BV <-  as.data.frame(bv(pop))
  BV$Gen <- unlist(pop@misc)
  MeanBV <- aggregate(BV[, 1:4], list(BV$Gen), mean)
  colnames(MeanBV)[1] <- "Generation"
  return(MeanBV)
}

CalcMeanDD <- function(pop){
  DD <-  as.data.frame(dd(pop))
  DD$Gen <- unlist(pop@misc)
  MeanDD <- aggregate(DD[, 1:4], list(DD$Gen), mean)
  colnames(MeanDD)[1] <- "Generation"
  return(MeanDD)
}



AssignBull_v <- function(pop, nVil, nBull_v){
  Bull_v = vector("list",nVil)
  names(Bull_v) = paste0("Village",c(1:nVil))
  
  nVillages
  BullOrder = sample( pop@id,size=nInd(pop),replace=F) #randomly sample CowIDs 
  
  for (i in (1:length(Bull_v))){ #For each Farm
    Bull_v[[i]] = pop[match(BullOrder[1:nBull_v],pop@id)]
    BullOrder = BullOrder[-c(1:nBull_v)] 
  }
  return(Bull_v)
}

AssignBull_f <- function(pop){
  Bull = vector("list",nFarms)
  names(Bull) = paste0("Farm",c(1:nFarms))
  BullOrder = sample(pop@id,size=nFarms,replace=F)
  for (f in (1:nFarms)){ 
    Bull[[f]] = pop[match(BullOrder[f],pop@id)]
  }
  
  Bull_f = vector("list",nVillages)
  names( Bull_f) = paste0("Village",c(1:nVillages))
  start=seq(1,nFarms,by=nFarms/nVillages) 
  stop=seq(nFarms/nVillages,nFarms,by=nFarms/nVillages)  
  for (each in (1:nVillages)){ #For each Village
    Bull_f [[each]] = Bull[FarmOrder[start[each]:stop[each]]] 
  }
  return(Bull_f)
}


AssignCow_v <- function(pop, nVil){
  Cow_v = vector("list",nVil)
  names(Cow_v) = paste0("Village",c(1:nVil))
  
  CowOrder = sample(pop@id,size=nInd(pop),replace=F) #randomly sample CowIDs 
  nCow_v <- nInd(pop)/nVil
  for (i in (1:length(Cow_v))){ #For each Farm
    Cow_v[[i]] = pop[match(CowOrder[1:nCow_v],pop@id)]
    CowOrder = CowOrder[-c(1:nCow_v)] 
  }
  return(Cow_v)
}


recordSelInt <- function(data = NULL, pops, pop, Strategy= NA) {
  popData = data.frame(Generation   = Gen,
                       #GEVariance   = varGE,
                       #AdditiveCor  = corA,
                       #Iteration    = Iter,
                       Strategy     = Strategy,
                       SelInt1        = (meanP(pops)["BodyWeight_local"] - meanP(pop)["BodyWeight_local"])/sqrt(varP(pop)["BodyWeight_local","BodyWeight_local"]), 
                       SelInt2        = (meanP(pops)["TickCount_local"] - meanP(pop)["TickCount_local"])/sqrt(varP(pop)["TickCount_local","TickCount_local"])
  )
  # Manage first instance of calling this function, when data is NULL
  if (is.null(data)) {
    ret = popData
  } else {
    ret = rbind(data, popData)
  }
  return(ret)
}

SumseltInt <- function(data = NULL, SelInt_v ) {
  sumd = do.call(rbind, SelInt_v)
  res = data.frame(Generation    = Gen,
                   #GEVariance   = varGE,
                   #AdditiveCor  = corA,
                   Strategy      = Strategy,
                   SelInt1       = mean(sumd[, "SelInt1"]), 
                   SelInt2       = mean(sumd[, "SelInt2"])
  )
  # Manage first instance of calling this function, when data is NULL
  if (is.null(data)) {
    ret = res
  } else {
    ret = rbind(data, res)
  }
  return(ret)
}



countQTL <- function(x) {length(which(x %in% c(0, 2)))/9000}
countSnp <- function(x) {length(which(x %in% c(0, 2)))/42000}
countSeg <- function(x) {length(which(x %in% c(0, 2)))/51000}

CompCoefInb <- function(data = NULL, pop ) {
  QTLGeno <- as.data.frame(pullQtlGeno(pop))
  QTLGenoc <- apply(QTLGeno, 1, countQTL)
  SnpGeno <- as.data.frame(pullSnpGeno(pop))
  SnpGenoc <- apply(SnpGeno, 1, countSnp)
  SegGeno <- as.data.frame(pullSegSiteGeno(pop))
  SegGenoc <- apply(SegGeno, 1, countSeg)
  
  res = data.frame(Generation   = Gen,
                   Strategy     = Strategy,
                   MeanCoefQTL  = mean(QTLGenoc),
                   SDCoefQTL    = sd(QTLGenoc),
                   MeanCoefSnp  = mean(SnpGenoc),
                   SDCoefSnp    = sd(SnpGenoc),
                   MeanCoefSeg  = mean(SegGenoc),
                   SDCoefSeg    = sd(SegGenoc))
  
  # Manage first instance of calling this function, when data is NULL
  if (is.null(data)) {
    ret = res
  } else {
    ret = rbind(data, res)
  }
  return(ret)
}


calcHeterosis <- function(popA, popB, hybPop) {
  inbMean = (meanG(popA) + meanG(popB))/2
  hybMean = meanG(hybPop)
  heterosis = meanG(hybPop) - (meanG(popA) + meanG(popB))/2
  perHeterosis = (hybMean-inbMean)/inbMean*100
  return(data.frame("Midparent value" = inbMean,
                    "Hybrid value" = hybMean,
                    "Heterosis" = heterosis,
                    "Percent heterosis" = perHeterosis))
}

#table(unlist(getMisc(x = mergePops(HybridRefPop_v), node = "yearOfBirth")))
#table(unlist(getMisc(x = ExoticRefPop, node = "yearOfBirth")))
