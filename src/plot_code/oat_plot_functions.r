#####################################################
#
# oat_plot_functions.r   16 FEB 2017
#
# Creates the one-at-a-time sensitivity plots
# for figure 5.
#
#####################################################

make.oatplot <- function(this.frame, make.legend=TRUE, 
                         rho.center=0, gamma.center=1, eta.center=1, c0.center=500, 
                         this.ylim=NULL, ...) {

  # Create a data frame that has the
  # parameter values normalized
  norm.frame <- this.frame[,c("rho","gamma","eta","c0")]
  norm.frame <- data.frame(apply(norm.frame, 2, .normalize))
  norm.frame <- data.frame(norm.frame, SCC=this.frame$SCC)
  
  # Normalize central values for parsing the norm.frame
  rho.c.norm <- .normalize(rho.center, range(this.frame$rho))
  gamma.c.norm <- .normalize(gamma.center, range(this.frame$gamma))
  eta.c.norm <- .normalize(eta.center, range(this.frame$eta))
  c0.c.norm <- .normalize(c0.center, range(this.frame$c0))
  
  # Get the appropriate SCC values
  rho.scc <- norm.frame[which(with(norm.frame, gamma==gamma.c.norm & eta==eta.c.norm & c0==c0.c.norm)),c("rho","SCC")]
  gamma.scc <- norm.frame[which(with(norm.frame, rho==rho.c.norm & eta==eta.c.norm & c0==c0.c.norm)),c("gamma","SCC")]
  eta.scc <- norm.frame[which(with(norm.frame, gamma==gamma.c.norm & rho==rho.c.norm & c0==c0.c.norm)),c("eta","SCC")]
  c0.scc <- norm.frame[which(with(norm.frame, gamma==gamma.c.norm & eta==eta.c.norm & rho==rho.c.norm)),c("c0","SCC")]
  
  # Make the plot
	my.ylim <- this.ylim
  par(...)
  plot.new()
  plot.window(xlim=c(0,1), ylim=my.ylim, log="")
  axis(1, at=c(0,1), labels=c("Min", "Max"))
  mtext("Parameter Range", 1, line=2)
  axis(2)
  mtext("SCC", 2, line=3.7, cex=0.9)
  mtext(expression(paste("[2015 USD per ton ", CO[2], "]", sep="")), 2, line=2.6, cex=0.9)
  box(bty="o")

  line.cols <- c("black", "#1b9e77", "#d95f02", "#7570b3")
  lines(gamma.scc[,1], gamma.scc[,2], col=line.cols[2])
  points(gamma.scc[,1], gamma.scc[,2], col=line.cols[2], pch=15, cex=0.85)
  lines(eta.scc[,1], eta.scc[,2], col=line.cols[3])
  points(eta.scc[,1], eta.scc[,2], col=line.cols[3], pch=16, cex=0.85)
  lines(c0.scc[,1], c0.scc[,2], col=line.cols[4])
  points(c0.scc[,1], c0.scc[,2], col=line.cols[4], pch=17, cex=0.85)
    
  if(make.legend){
    legend("top", horiz=F, legend=c("gamma", "eta", "c0"), lty=1, pch=15:17, col=line.cols[-1], bty="n", cex=0.8)
  }
}

# Normalize a vector
.normalize <- function(x, x.range=NULL, ...) {
  if(is.null(x.range)) {
    (x - min(x, ...)) / (max(x, ...) - min(x, ...))
  }
  else {
    (x-x.range[1]) / (x.range[2] - x.range[1])
  }
}