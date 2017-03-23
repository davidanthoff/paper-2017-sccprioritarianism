#################################################
#
# make_figure_4.r    16 FEB 2017
#
# Generates figure 4 in "Priority for the
# worse off and the Social Cost of Carbon". This
# code is meant to be sourced from make_figures.r
# and not necessarily run on its own.
#
#################################################

# Setup the plotting device
outfile <- paste(plotdir, "/figure4.pdf", sep="")
pdf(outfile, width=8, height=6)

# Make this a 4-panel plot
par(mfrow=c(2,2), mar=c(4.5,5,2.5,1)+0.1)

# y-axis limits
temp.ylims <- matrix(c(0,650,0,5500,0,850,0,1100), ncol=2, byrow=T)

# Loop over the regions
for(i in 1:length(norm.regions)) {
  
  # Define the current run
  this.run <- norm.regions[i]
  
  # Subset the data frame for this region
  util.subset <- my.data[which(with(my.data, focusregion == this.run & 
                                      eta <= 3.0 & eta >= 0.0 &
                                      rho == 0.01 & gamma == 0 & c0 == 1)),]
  prior.subset <- my.data[which(with(my.data, focusregion == this.run & 
                                       eta <= 3.0 & eta >= 0.0 &
                                       gamma == 1.0 & rho == 0 & c0 == 500)),]
  
  # Setup the plotting parameters
  my.ylim <- temp.ylims[i,]
  line.cols <- c("magenta", "cyan")
  region.label <- this.run
  #if(region.label == "World") {region.label <- "Global"}
  
  # Make the plot
  plot(util.subset$eta, util.subset$SCC, type="l", ylim=my.ylim, col=line.cols[1],
       xlab="eta [-]", ylab="", main=region.label, log="")
  points(util.subset$eta, util.subset$SCC, pch=15, col=line.cols[1])
  mtext("SCC", 2, line=3.7)
  mtext(expression(paste("[2015 USD per ton ", CO[2], "]", sep="")), 2, line=2.5)
  lines(prior.subset$eta, prior.subset$SCC, col=line.cols[2])
  points(prior.subset$eta, prior.subset$SCC, pch=16, col=line.cols[2])
  legend("topright", legend=c("Disc. Utilitarian", "Undisc. Prioritarian"),
         lty=1, pch=c(15,16), col=line.cols, bty="n")
  put.fig.letter(letters[i], font=2, cex=1.2, offset=c(0.01, -0.05))
  
}

# Turn off the plotting device if necessary
dev.off()