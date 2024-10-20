# ----  Set up the environment ----

options(warn = 1, bitmapType = 'cairo')
.libPaths("/scratch/agKoenig/vanvanhossous/r_lib")

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

  # Composite "farm bull"
  source("Cross_Composite_FB.R")

  # Composite "intra-village bull"
  source("Cross_Composite_IVB.R")

  # Composite "extra-village bull"
  source("Cross_Composite_EVB.R")

  # Composite "population-wide bull"
  source("Cross_Composite_PWB.R")

  # Rotational
  source("Cross_Rotational.R")

  # Terminal
  source("Cross_Terminal.R")
}
