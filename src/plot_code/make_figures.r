#################################################
#
# make_figures.r    16 FEB 2017
#
# Generates figures 2-5 in "Priority for the
# worse off and the Social Cost of Carbon".
#
#################################################

# Directories
scriptdir <- "."
datadir <- "../../results"
plotdir <- "../../plots"

# Libraries
library(RColorBrewer)
library(lattice)
library(fields)
source(paste(scriptdir, "/put_fig_letter.r", sep=""))
source(paste(scriptdir, "/oat_plot_functions.r", sep=""))
source(paste(scriptdir, "/contour_plot_functions.r", sep=""))

# Load the data
infile <- paste(datadir, "/output-scc.csv", sep="")
my.data <- read.csv(infile, header=T)

# List of the normalization regions of interest
norm.regions <- c("Africa", "US", "Global", "World-Fair")

# Generate the figures
source(paste(scriptdir, "/make_figure_2.r", sep=""))
source(paste(scriptdir, "/make_figure_3.r", sep=""))
source(paste(scriptdir, "/make_figure_4.r", sep=""))
source(paste(scriptdir, "/make_figure_5.r", sep=""))

# Done!