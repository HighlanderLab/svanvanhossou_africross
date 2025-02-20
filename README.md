# svanvanhossou_africross

## Overview

This repository contains AlphaSimR scripts used to simulate crossbreding scenarios
in African cattle production system with smallholders and large differences between
local and exotic breeds in terms of production and adaptation traits. Details of
the study are available in:

    Sèyi Fridaius Ulrich Vanvanhossou, Tong Yin, Gregor Gorjanc, Sven König
    Evaluation of crossbreeding strategies for improved adaptation and productivity in African smallholder cattle farms.
    Genetics Selection Evolution
    https://gsejournal.biomedcentral.com/articles/10.1186/s12711-025-00952-8

You need AlphaSimR version 1.6.0 or higher to run the scripts.

The code is organised in different areas as follows:
- Main,
- Custom functions,
- Simulation parameters,
- Founder populations,
- Local and exotic breeds,
- Villages and farms
- Crossbreeding - synthetic "farm bull"
- Crossbreeding - synthetic "intra-village bull"
- Crossbreeding - synthetic "extra-village bull"
- Crossbreeding - synthetic "population-wide bull"
- Crossbreeding - rotational
- Crossbreeding - F1

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

## Simulation parameters

##### Code

    SimParameters.R

##### Description

All key simulation parameters are stored and driven from this file. See also
`CreateFounderPops.R` and `CreateLocalAndExoticBreeds.R`.

## Founder populations
  
##### Code

    CreateFounderPops.R

##### Description

In this script we used values from `SimParameters.R` and simulated:
- a cattle genome with 30 chromosome pairs for 5,000 founder individuals;
  we tracked 300 QTL and 1400 SNP on each chromosome.
- two complex traits with additive and dominance genetic effects:
  - body weight (productive trait with moderate heritability) and
  - tick count incidence (i.e., `-log10[tick count]`, adaptive trait with low heritability).

We assumed: 
- a population split 20.000 generations ago corresponding to 100.000 years split
  between Taurine and Indicine cattle
- all the traits are controlled by the same pleiotropic QTL having correlated effects
- the same heritability in the two breeds but different phenotypic mean and variance
  in the two breeds, leading to 2 x 2 = 4 simulated traits
- different genetic correlations between body weight and tick count incidence (0, -0.4, -0.2, 0.2, 0.4)
- GxE effects simulated as genetic correlation between (the same trait in) the breeds, and
  i.e, between local and exotic environment; we tested different values : 0.6, 0.8, 0.4.

## Local and exotic breeds

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

## Villages and farms

##### Code

    CreateFarmsAndVillages.R

##### Description

In this script, we used values from `SimParameters.R` and simulated smallholder farms and villages. 
- farms were simulated by randomly sampling cows from generation 20 of the local breed. 
- the villages were randomly assigned the simulated farms, and local and exotic bulls from generation 20.

We assumed 
- 200 smallholders farms
- eight to 40 cows per farm (farm size were randomly sampled, and therefore varied between replicates)
- 10 villages (each composed of 20 smallholders farms)
- 5 bulls per village (assuming artificial insemination).

## Crossbreeding - synthetic "farm bull"

##### Code

    Cross_synthetic_FB.R

##### Description

In this script, we simulated synthetic breeding following the "farm bull" scheme. 
- a first generation of crossbred animals (G21) were produced by mating local cows
  from the smallholder farms with exotic bulls.
- one crossbred bull was selected per farm and mated with crossbred cows from the same farm to produce
  offsprings over 19 subsequent generations (implying closed matings of relatives at the farm level)

We assumed 
- phenotypic selection using a multi-trait selection index including body weight and tick count incidence
  for the crossbred cows and bulls (see `SimParameters.R`).

## Crossbreeding - synthetic "intra-village bull"

##### Code

    Cross_synthetic_IVB.R

##### Description

In this script, we simulated synthetic breeding following the "intra-village bull" scheme. 
- a first generation of crossbred animals (G21) were produced by mating local cows
  from the smallholder farms with exotic bulls.
- five best crossbred bulls in a village (i) were selected and randomly allocated
  to farms located in the same village (i). 

We assumed 
- phenotypic selection using a multi-trait selection index including body weight and tick
  count incidence for the crossbred cows and bulls (see `SimParameters.R`).
- a cooperation between farmers from the same village for the exchanges of semen. 

## Crossbreeding - synthetic "exchanged-village bull"

##### Code

    Cross_synthetic_EVB.R

##### Description

In this script, we simulated synthetic breeding following the "exchanged-village bull" scheme. 
- a first generation of crossbred animals were produced by mating local 
  cows from the smallholder farms with exotic bulls.
- five best crossbred bulls in a village (i) were selected and randomly allocated
  to farms located in another village (j).
- the village j was randomly chosen at each generation and should differed from
  village i.

We assumed 
- phenotypic selection using a multi-trait selection index including body weight and tick
  count incidence for the crossbred cows and bulls (see `SimParameters.R`).
- a cooperation between farmers from different villages for the exchanges of semen among villages.

## Crossbreeding - synthetic "population-wide bull"

##### Code

    Cross_synthetic_PWB.R

##### Description

In this script, we simulated synthetic breeding following the "population-wide bull" scheme. 
- a first generation of crossbred animals were produced by mating local 
  cows from the smallholder farms with exotic bulls.
- the 50 best bulls were selected and randomly assigned to the farms regardless of their
  initial farm and village origin
  - all candidate crossbred bulls from the simulated smallholder farms were pooled together.
  - this strategy implyed variable number of selected bulls per village (in contrast to
    the other synthetic schemes). 

We assumed 
- phenotypic selection using a multi-trait selection index including body weight and tick
  count incidence for the crossbred cows and bulls (see `SimParameters.R`).


## Crossbreeding - Rotational

##### Code

    Cross_Rotational.R

##### Description

In this script, we simulated Rotational crossbreeding. 
- a first generation of crossbred animals were produced by mating local 
  cows from the smallholder farms with exotic bulls.
- crossbred cows from the smallholder farms were mated with local and exotic bulls at even
  and odd generations, respectively, to produce crossbred offsprings over 19 subsequent generations.

We assumed 
- a local nucleus herd of 2000 cows delivering semen from 50 local bulls to the smallholder farms.
  - The local nucleus herd also serve at preserving the local breed for its adaptive traits.
- an exotic nucleus herd (a foreign herd) of 2000 cows delivering semen from 50 exotic bulls
  to the smallholder farms.
- phenotypic selection using a multi-trait selection index including body weight and tick
  count incidence for the crossbred cows (see `SimParameters.R`).
- phenotypic selection targeting (lower) tick count incidence for the local breed
- genomic selection targeting (higher) body weight for the exotic breed.


## Crossbreeding - F1

##### Code

In this script, we simulated the production of F1 animals over 20 generations. 
- local cows from smallholder farms were mated with exotic bulls to produce F1 animals at each generation.

We assumed 
- a pure line of local animals was kept in each smallholder farm, in parallel to the crossbreeding scheme. 
  - Each local cow were mated twice: with an exotic bull to produced a F1 offspring, and with a local bull
  to produce a local offspring.
  - The local cows and bulls were selected from the local progenies to serve as parents for the next generation.
  - This strategy ensure the availability of local cows at each generation for ongoing production of F1 animals
    on the smallholder farms (but is not feasible in practical setting)
- an exotic nucleus herd (a foreign herd) of 2000 cows delivering semen from 50 exotic bulls
  to the smallholder farms.
- phenotypic selection targeting (lower) tick count incidence for the local animals
- genomic selection targeting (higher) body weight for the exotic breed.
