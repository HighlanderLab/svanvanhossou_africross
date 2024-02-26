
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
                       SdPheno_TCe   = sqrt(varP(pop)["TickCount_exotic","TickCount_exotic"])
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
