# ----  Set up the environment ----

options(warn = 1, bitmapType = 'cairo')

if (!dir.exists(paste0("./Results"))) {dir.create(paste0("./Results"))}

# ---- Load packages ----

AlphaSimRVersion <- packageVersion(pkg = "AlphaSimR")
if (!(AlphaSimRVersion >= "1.6.0")) {
  stop(paste("We have AlphaSimR version", AlphaSimRVersion, "\n",
             "but require 1.6.0 or above!"))
}
library(package = "AlphaSimR")
library(package = "gdata")

# ---- Simulation with 40 replicates ----

for (Rep in 1:40) {
  # Rep <- 1
  rm(list = ls())
  cwd <- getwd()

  # ---- Functions, parameters, founders, breeds, and farms ----

  # Custom functions
  source("Functions.R")

  # Simulation parameters
  source("SimParameters.R")

  # Founder populations
  source("CreateFounderPops.R")

  # Local and exotic breeds
  source("CreateLocalAndExoticBreeds.R")

  # Villages and farms
  source("CreateFarmsAndVillages.R")

  # ---- Crossbreeding strategies ----

  # Synthetic "farm bull"
  source("Cross_Synthetic_FB.R")

  # Synthetic "intra-village bull"
  source("Cross_Synthetic_IVB.R")

  # Synthetic "extra-village bull"
  source("Cross_Synthetic_EVB.R")

  # Synthetic "population-wide bull"
  source("Cross_Synthetic_PWB.R")

  # Rotational
  source("Cross_Rotational.R")

  # F1 (Terminal)
  source("Cross_F1.R")
}
