#################################################
#
# make_figure_2.r    16 FEB 2017
#
# Generates figure 2 in "Priority for the
# worse off and the Social Cost of Carbon". This
# code is meant to be sourced from make_figures.r
# and not necessarily run on its own.
#
#################################################

# Setup the plotting device
outfile <- paste(plotdir, "/figure2.pdf", sep="")
pdf(outfile, width=7, height=12)

# Make the subsets of data
util.subset <- my.data[which(with(my.data, focusregion %in% norm.regions & 
                                    eta <= 3.0 & eta >= 0.0 &
                                    rho >= 0.0 & rho <= 0.03 &
                                    gamma == 0 & c0 == 1)),]
prior.subset <- my.data[which(with(my.data, focusregion %in% norm.regions & 
                                     eta <= 3.0 & eta >= 0.0 &
                                     gamma <= 3.0 & gamma >= 0.0 &
                                     rho == 0 & c0 == 500)),]

# Cap the SCC to the zlim range
my.zlim <- c(0,10000)
util.subset[which(with(util.subset, SCC<my.zlim[1])),"SCC"] <- my.zlim[1]
util.subset[which(with(util.subset, SCC>my.zlim[2])),"SCC"] <- my.zlim[2]
prior.subset[which(with(prior.subset, SCC<my.zlim[1])),"SCC"] <- my.zlim[1]
prior.subset[which(with(prior.subset, SCC>my.zlim[2])),"SCC"] <- my.zlim[2]

# Put the rho values in the util frame into percentage values
util.subset$rho <- util.subset$rho * 100

# Colors for plots
scc.cols <- colorRampPalette(c(brewer.pal(8, "PuOr"), "black"), bias=1.7)(100)

# Define zoom level for plots
my.zoom <- 0.7

# Define distance of axis labels from the plot
my.dist <- c(1.2,1.2,1.2)

# Axis label locations and labels
at.eta <- 0:3
labels.eta <- c("0",rep("", length(at.eta)-2),"3")
at.gamma <- 0:3
labels.gamma <- c("0","","","3")
at.rho <- 0:3
labels.rho <- c("0","","","3")
my.ztics <- c(0,10000)

# Generate the plot panels
util.plot <- wireframe(SCC ~ eta+rho|focusregion, util.subset, zoom=my.zoom,
                       screen=list(x=-70,y=-50,z=-15), index.cond=list(c(4,2,3,1)),
                       scales=list(arrows=F, x=list(at=at.eta, labels=labels.eta), y=list(at=at.rho, labels=labels.rho), z=list(at=my.ztics, labels=c(0,parse(text="10^4"))), distance=my.dist), 
                       drape=T, col.regions=scc.cols, layout=c(1,4),
                       colorkey=list(at=seq(my.zlim[1], my.zlim[2], l=101), col=scc.cols))

prior.plot <- wireframe(SCC ~ eta+gamma|focusregion, prior.subset, zlim=my.zlim,  zoom=my.zoom,
                        screen=list(x=-70,y=-50,z=-15), index.cond=list(c(4,2,3,1)),
                        scales=list(arrows=F, x=list(at=at.eta, labels=labels.eta), y=list(at=at.gamma, labels=labels.gamma), z=list(at=my.ztics, labels=c(0,parse(text="10^4"))), distance=my.dist), 
                        drape=T, col.regions=scc.cols, layout=c(1,4),
                        colorkey=list(at=seq(my.zlim[1], my.zlim[2], l=101), col=scc.cols))

# Print the two panels side by side
print(util.plot, position=c(0,0,0.5,1), more=T)
print(prior.plot, position=c(0.5,0,1,1))

# Turn off the plotting device if necessary
dev.off()