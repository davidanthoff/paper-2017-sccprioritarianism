#################################################
#
# make_figure_5.r    16 FEB 2017
#
# Generates figure 5 in "Priority for the
# worse off and the Social Cost of Carbon". This
# code is meant to be sourced from make_figures.r
# and not necessarily run on its own.
#
#################################################

# Setup the subset parameters for this plot series
run.names <- c("Africa", "US", "Global", "World-Fair")
my.eta.range <- c(0,3)
my.gamma.range <- c(0,3)
  
# Open a plotting device
outfile <- paste(plotdir, "/figure5.pdf", sep="")
pdf(outfile, width=7, height=5)
par(mfrow=c(2,2))
  
# Cycle through the appropriate regions
for(i in 1:length(norm.regions)) {
  
  # Get the run
  this.run <- norm.regions[i]
    
  # Subset the data
  this.subset <- my.data[which(with(my.data, focusregion == this.run &
                                      eta <= 3.0 & eta >= 0.0 &
                                      gamma <= 3.0 & gamma >= 0.0)),]
  
  # Generate the OAT plot for this run
  temp.ylims <- matrix(c(0,150,1550,3550,0,800,0,800), ncol=2, byrow=T)
  make.oatplot(this.subset, make.legend=T, mar=c(4,4.5,1.5,1)+0.1, this.ylim = temp.ylims[i,])
  mtext(this.run, side=3, line=0.2, cex=1.0, font=2)
  
  # Put a figure letter on this panel
  put.fig.letter(letters[i], font=2, offset = c(0, -0.01))   # Lowercase
  
}
  
# Turn off plotting device
dev.off()