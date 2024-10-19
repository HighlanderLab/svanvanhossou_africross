# svanvanhossou_africross

## Overview

This repository contains AlphaSimR scripts used to simulate crossbreding scenarios
in African cattle production system with smallholders and large differences between
local and exotic breeds in terms of production and adaptation traits. Details of
the study are available in:

    Sèyi Fridaius Ulrich Vanvanhossou, Tong Yin, Gregor Gorjanc, Sven König (2024)
    Evaluation of crossbreeding strategies for improved adaptation and productivity
    in African smallholder cattle farms.
    Under review in Genetics Selection Evolution.

The code is organised in different areas as follows:
- Main,
- Custom functions,
- Simulation Parameters,
- Simulation of founder populations,
- Simulation of a local and exotic breeds,
- TODO

The rest of this document provides a brief description of each area.

## Main

##### Code

    MainScript.R

##### Description

This script is used to setup the simulation environment, sources all the other
scripts to setup parameters, populations, villages with farms, runs different
scenarios, and rund replicates.

## Custom functions

##### Code

    Functions.R

##### Description

These are custom functions in R for specific tasks, e.g., calculate average
phenotypic and genetic values, and further statistical analyses.

## Simulation Parameters

##### Code

    SimParameters.R

##### Description

All key simulation parameters are stored and driven from this file. See also
`CreateFounderPops.R` and TODO

## Simulation of founder populations
  
##### Code

    CreateFounderPops.R

##### Description

In this script we used values from `SimParameters.R` and simulated:
- a cattle genome with 30 chromosome pairs for 5,000 founder individuals;
  we tracked 300 QTL and 1400 SNP on each chromosome.
- two complex traits with additive and dominance egenetic ffects:
  - body weight (productive trait with moderate heritability) and
  - tick count (adaptive trait with low heritability).

We assumed: 
- a population split 20.000 generations ago corresponding to 100.000 years split
  between Taurine and Indicine cattle (TODO: where is this done??! We don't have a split!)
- all the traits are controlled by the same pleiotropic QTL having correlated effects
- the same heritability in the two breeds but different phenotypic mean and variance
  in the two breeds, leading to 2 x 2 = 4 simulated traits
- different genetic correlations between body weight andtick count (0, -0.4, -0.2, 0.2, 0.4)
- GxE effects simulated as genetic correlation between (the same trait in) the breeds, and
  i.e, between local and exotic environment; we tested different values : 0.6, 0.8, 0.4.

## Simulation of a local and exotic breed 

##### Code

    CreateLocalAndExoticBreeds.R

##### Description

In this script, we simulated purebred development over 20 generations in the
local and exotic breeds separately to generate trait-specific linkage-disequilibrium
in each breed.

We assumed 
- phenotypic selection targeting (lower) tick count for the local breed
- genomic selection targeting (higher) body weight for the exotic breed.

The Fst value between the two breeds at generation 20 is approximately equal to
0.3, which is in accordance with the genetic distance between African taurine and
Asian indicine as reported by Kim et al. (2020) [see citation in our publication].
