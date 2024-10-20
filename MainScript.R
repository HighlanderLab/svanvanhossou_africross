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

  # Load functions
  source("Functions.R")

  # Simulation Parameters
  source("SimParameters.R")

  # Simulation of founder populations
  source("CreateFounderPops.R")

  # Simulation of local and exotic breeds
  source("CreateLocalAndExoticBreeds.R")

  # Simulation of local farms and villages
  source("CreateFarmsAndVillages.R")

  # ---- Crossbreeding strategies ----

  # Composite Farm bull
  source("Cross_Composite_FB.R")

  # Composite Intra village bull
  source("Cross_Composite_IVB.R")

  # Composite Extra village bull
  source("Cross_Composite_EVB.R")

  # Composite Population wide bull
  source("Cross_Composite_PWB.R")

  # Rotational
  source("Cross_Rotational.R")

  # Terminal
  source("Cross_Terminal.R")
}
