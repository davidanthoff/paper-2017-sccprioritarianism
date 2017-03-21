#################################################
#
# make_figure_3.r    16 FEB 2017
#
# Generates figure 3 in "Priority for the
# worse off and the Social Cost of Carbon". This
# code is meant to be sourced from make_figures.r
# and not necessarily run on its own.
#
#################################################

# Setup the plotting device
outfile <- paste(plotdir, "/figure3.pdf", sep="")
pdf(outfile, width=8, height=12)

# Set the plot range exponents
my.exp.lo <- -1
my.exp.hi <- 4
my.scc.range <- c(0,10000)
scc.legend.lab <- expression(paste("Social Cost of Carbon [2015 USD per ton ", CO[2], "]", sep=""))
scc.cols <- colorRampPalette(c(brewer.pal(8, "PuOr"), "black"), bias=0.45)(100)

# Loop over the regions
for(i in 1:length(norm.regions)) {
  
  # Define the vertical plotting area for this panel
  vert.area <- c(1-(i*0.22), 1-((i-1)*0.22))
  
  # Define the current run
  this.run <- norm.regions[i]
  
  # Subset the data frame for this region
  util.subset <- my.data[which(with(my.data, focusregion == this.run & 
                                      eta <= 3.0 & eta >= 0.0 &
                                      rho >= 0.0 & rho <= 0.03 &
                                      gamma == 0 & c0 == 1)),]
  prior.subset <- my.data[which(with(my.data, focusregion == this.run & 
                                       eta <= 3.0 & eta >= 0.0 &
                                       gamma <= 3.0 & gamma >= 0.0 &
                                       rho == 0 & c0 == 500)),]
  
  # Make the 3d plots
  if(i == 1) {
    par(fig=c(0,0.5, vert.area))
  }
  else {
    par(fig=c(0,0.5, vert.area), new=T)
  }
  make.3dcontour.rho.eta(util.subset, scc.cols = scc.cols, 
                         scc.range=my.scc.range, exp.lo=my.exp.lo, exp.hi=my.exp.hi, make.cbar=F)
  put.fig.letter(letters[(2*i)-1], font=2, cex=1.2, offset=c(0.01, -0.05))
  
  par(fig=c(0.5,1, vert.area), new=T)
  make.3dcontour(prior.subset, scc.cols = scc.cols, 
                 scc.range=my.scc.range, exp.lo=my.exp.lo, exp.hi=my.exp.hi, make.cbar=F)
  put.fig.letter(letters[2*i], font=2, cex=1.2, offset=c(0.01, -0.05))
  
}

# Plot a color bar across the bottom
par(fig=c(0,1,0,1), new=T)
image.plot(legend.only=T, horizontal=T, smallplot=c(0.1,0.9,0.08,0.1),
           zlim=c(my.exp.lo,my.exp.hi), breaks=seq(my.exp.lo,my.exp.hi,l=101), col=scc.cols, legend.line=2.2,
           axis.args = list(at=my.exp.lo:my.exp.hi, labels=parse(text=paste("10^", my.exp.lo:my.exp.hi, sep=""))),
           legend.lab=scc.legend.lab)

# Turn off the plotting device if necessary
dev.off()