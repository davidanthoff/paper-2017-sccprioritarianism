#####################################################
#
# contour_plot_functions.r   16 FEB 2017
#
# Functions that create the contour plots for
# figure 3.
#
#####################################################

make.3dcontour <- function(this.frame, scc.cols, scc.range=c(0,10000), exp.lo=NULL, exp.hi=NULL, make.cbar=T, ...) {
  
  # Get the old margins to reset later
  old.margins <- par("mar")
  
  # Get the levels of rho and c0
  these.rho <- unique(this.frame$rho)
  these.c0 <- unique(this.frame$c0)
  
  # Loop over the available rho values
  for(this.rho in these.rho) {
    
    # Loop over the available c0 values
    for(this.c0 in these.c0) {
      
      # Subset this.frame
      this.subframe <- this.frame[which(with(this.frame, rho==this.rho & c0==this.c0)),]
      
      # If SCC range is out of bounds, limit the plot
      this.subframe[which(with(this.subframe, SCC<scc.range[1])),"SCC"] <- scc.range[1]
      this.subframe[which(with(this.subframe, SCC>scc.range[2])),"SCC"] <- scc.range[2]
      
      # Make the temporary matrix to hold SCC
      temp <- matrix(this.subframe$SCC, nrow=length(unique(this.subframe$gamma)), byrow=T)
      
      # Exponent limits
      if(is.null(exp.lo)) {exp.lo <- floor(log10(min(temp[temp>=scc.range[1]]))) }
      if(is.null(exp.hi)) {exp.hi <- ceiling(log10(max(temp[temp<=scc.range[2]]))) }
      
      # Make the plot
      par(mar=c(4.5,4.5,2,1)+0.1)
      if(make.cbar) {
        image.plot(unique(this.subframe$gamma), unique(this.subframe$eta), log10(temp),
                 xlab="gamma [-]", ylab="eta [-]", breaks=seq(exp.lo,exp.hi,l=101), col=scc.cols,
                 axis.args = list(at=exp.lo:exp.hi, labels=parse(text=paste("10^", exp.lo:exp.hi, sep=""))))
      }
      else {
        image(unique(this.subframe$gamma), unique(this.subframe$eta), log10(temp),
                   xlab="gamma [-]", ylab="eta [-]", breaks=seq(exp.lo,exp.hi,l=101), col=scc.cols)
      }
      box()
      mtext(unique(this.subframe$focusregion), 3, line=0.25, cex=1.3)
      par(mar=old.margins)

    }
  }
}


make.3dcontour.rho.eta <- function(this.frame, scc.cols, scc.range=c(0,10000), exp.lo=NULL, exp.hi=NULL, make.cbar=T, ...) {
  
  # Get the old margins
  old.margins <- par("mar")
  
  # If SCC range is out of bounds, limit the plot
  this.frame[which(with(this.frame, SCC<scc.range[1])),"SCC"] <- scc.range[1]
  this.frame[which(with(this.frame, SCC>scc.range[2])),"SCC"] <- scc.range[2]
  
  # Cast rho as a percent
  this.frame$rho <- this.frame$rho * 100
  
  # Make the temporary matrix to hold SCC
  temp <- matrix(this.frame$SCC, nrow=length(unique(this.frame$rho)), byrow=T)
  
  # Exponent limits
  if(is.null(exp.lo)) {exp.lo <- floor(log10(min(temp[temp>=scc.range[1]]))) }
  if(is.null(exp.hi)) {exp.hi <- ceiling(log10(max(temp[temp<=scc.range[2]]))) }
  
  # Make the 3d contour plot
  par(mar=c(4.5,4.5,2,1)+0.1)
  if(make.cbar) {
    image.plot(unique(this.frame$rho), unique(this.frame$eta), log10(temp),
             xlab="rho [%]", ylab="eta [-]", breaks=seq(exp.lo,exp.hi,l=101), col=scc.cols,
             axis.args = list(at=exp.lo:exp.hi, labels=parse(text=paste("10^", exp.lo:exp.hi, sep=""))))
  }
  else {
    image(unique(this.frame$rho), unique(this.frame$eta), log10(temp),
               xlab="rho [%]", ylab="eta [-]", breaks=seq(exp.lo,exp.hi,l=101), col=scc.cols)
  }
  box()
  mtext(unique(this.frame$focusregion), 3, line=0.25, cex=1.3)
  par(mar=old.margins)
  
}