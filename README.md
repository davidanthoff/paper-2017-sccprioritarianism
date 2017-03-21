# Replication code for Adler et al. (2017) "Priority for the worse off and the Social Cost of Carbon"

This repository holds all code required to replicate the results of Adler et al. (2017).

## Software requirements

You need to install [julia](http://julialang.org/) and [R](https://www.r-project.org/) to run the replication code.

## Preparing the software environment

On the julia side of things you need to install a number of packages. You can use the following julia code to do so:

````julia
Pkg.add("Mimi")
Pkg.add("DataFrames")
Pkg.add("ProgressMeter")
Pkg.add("RCall")
Pkg.add("ExcelReaders")
````

On the R side of things you also need to install a number packages. You can use the following R code to do so:

````R
install.packages("RColorBrewer")
install.packages("lattice")
install.packages("fields")
````

## Cloning the repository

This git repository uses a git submodule. To ensure the submodule gets properly downloaded, make sure to use the
git ``--recurse-submodules`` option when cloning the repository. If you cloned the repository without that option,
you can issue the following two git commands to make sure the submodule is present on your system:
``git submodule init``, followed by ``git submodule update``.

## Running the replication script

To recreate all outputs for this paper, run the ``main.jl`` file in the folder ``src`` with this command:

````
julia src/main.jl
````

## Result files

All results will be stored in csv files in the folder ``results``. The following files will be created by running the main script.

### results/output-scc.csv

This file contains estimate of the Social Cost of Carbon for various calibrations of preference parameters and welfare functions. The figures are in 2015 USD. The unit of the SCC results is $/tCO2 (NOT $/tC). The columns of the file have the following interpretation:

1. "model": the name of the model used to estimate the SCC (always "RICE").
2. "aggregation": for "Global" the world is treated as one big regions, for "Regional" each region is separatly represented in the welfare function.
3. "focusregion": the normalization region.
4. "rho": as defined in the manuscript.
5. "gamma": as defined in the manuscript.
6. "eta": as defined in the manuscript.
7. "c0": as defined in the manuscript.
8. "SCC": Social Cost of Carbon.

### results/output-marginaldamage.csv

The file contains the marginal damage caused by the release of one extra ton of carbon (C) in the year 2015 by year and region. The figures are in 2015 USD. The unit is $/tC (NOT $/tCO2).

### results/output-cpc.csv

This file contains per capita consumption levels from RICE-2010 by year and region. The figures are in 2015 USD.

### results/output-population.csv

This file contains population levels from RICE-2010 by year and region.

## Result plots

All plots for the paper will be stored in the ``plots`` folder.
