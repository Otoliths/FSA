#' @title Adds model fits from nls iterations to active plot.
#'
#' @description Adds model fits from iterations of the \code{\link[stats]{nls}} algorithm as returned when \code{trace=TRUE}.  Useful for diagnosing model fitting problems or issues associated with starting values.
#'
#' @details Nonlinear models fit through the \code{\link[stats]{nls}} function start with starting values for model parameters and iteratively search for other model parameters that continuously reduced the residual sum-of-squares (RSS) until some pre-determined criterion suggest that the RSS cannot be (substantially) further reduced.  With good starting values and well-behaved data the minimum RSS may be found in a few (<10) iterations.  However, poor starting values may lead to a prolonged search.  Poor starting values or pooly behaved data may lead to a failed search.  An understanding of iterations in a prolonged or failed search may lead to understanding why this happened or lead to choices that may lead to a more successful search.  The \code{trace=TRUE} argument of \code{\link[stats]{nls}} allows one to see the values at each iterative step.  This function takes the \dQuote{trace} results to plot the function at each step on a previously existing plot, thus providing a visual of the iterative process.
#' 
#' The \code{object} argument may an object saved from a successful run of \code{\link[stats]{nls}}.  See the \code{SpotVA1} and \code{CodNorwegion} examples.
#' 
#' However, if \code{\link[stats]{nls}} fails to converge to a solution then the \code{\link[stats]{nls}} does not return a useful object to be given to this function.  In this case, \code{trace=TRUE} should be added to the failed \code{\link[stats]{nls}} call, which should then be wrapped in \code{\link{try}} to work-around the error returned from \code{\link[stats]{nls}} not converging to a solution and then in to capture the \dQuote{trace} results.  The result from \code{\link[utils]{capture.output}} should in turn be saved to an object that is then given to \code{object} of this function.  See the \code{BSkateGB} example.
#' 
#' The function in \code{fun} is used to make predictions given the model parameter values at each step of the iteration.  This function must accept the explanatory/independent variable as its first argument and values for all model parameters in a vector as its second argument. These types of functions are returned by \code{\link{vbFuns}}, \code{\link{GompertzFuns}}, \code{\link{logisticFuns}}, and \code{\link{RichardsFuns}} for common growth models and \code{\link{srFuns}} for common strock-recruitment models.  See examples.
#'
#' @note The position of the \dQuote{legend} can be controlled in three ways.  First, if \code{legend=TRUE}, then the R console is suspended until the user places the legend on the plot by clicking on the point where the upper-left corner of the legend should appear.  Second, \code{legend=} can be set to one of \code{"bottomright"}, \code{"bottom"}, \code{"bottomleft"}, \code{"left"}, \code{"topleft"}, \code{"top"}, \code{"topright"}, \code{"right"} and \code{"center"}.  In this case, the legend will be placed inside the plot frame at the given location.  Finally, \code{legend=} can be set to a vector of length two which identifies the plot coordinates for the upper-left corner of where the legend should be placed.  A legend will not be drawn if \code{legend=FALSE} or \code{legend=NULL}.
#' 
#' @param object An object saved from \code{\link[stats]{nls}} or from \code{\link[utils]{capture.output}} using \code{\link{try}} with \code{\link[stats]{nls}}.  See details.
#' @param fun A function that represents the model being fit in \code{\link[stats]{nls}}. This must take the x-axis variable as the first argument and model parameters as a vector in the second argument.  See details.
#' @param from,to The range over which the function will be plotted.  Defaults to range of the x-axis of the active plot.
#' @param n The number of value at which to evaluate the function for plotting (i.e., the number of values from \code{from} to \code{to}).  Larger values make smoother lines.
#' @param lwd A numeric used to indicate the line width of the fitted line.
#' @param pal A character that is the name of a palette.  Must be one of \dQuote{rich}, \dQuote{cm}, \dQuote{default}, \dQuote{grey}, \dQuote{gray}, \dQuote{heat}, \dQuote{jet}, \dQuote{rainbow}, \dQuote{topo}, or \dQuote{terrain}, which are given in \code{paletteChoices}.
#' @param rev.col A logical that indicates that the order of colors for plotting the lines should be reversed.
#' @param legend Controls use and placement of the legend.  See details.
#' @param cex.leg A single numeric value that represents the character expansion value for the legend.  Ignored if \code{legend=FALSE}.
#' @param box.lty.leg A single numeric values that indicates the type of line to use for the box around the legend.  The default is to not plot a box.
#' @param add A logical indicating whether the lines should be added to the existing plot (defaults to \code{=TRUE}).
#' 
#' @return A matrix with the residual sum-of-squares in the first column and parameter estimates in the remaining columns for each iteration (rows) of \code{\link[stats]{nls}} as provided when \code{trace=TRUE}.
#' 
#' @author Derek H. Ogle, \email{derek@@derekogle.com}
#'
#' @keywords plot
#'
#' @examples
#' ## Examples following a successful fit
#' data(SpotVA1)
#' vb1 <- vbFuns()
#' fit1 <- nls(tl~vb1(age,Linf,K,t0),data=SpotVA1,start=list(Linf=12,K=0.3,t0=0))
#' plot(tl~age,data=SpotVA1,pch=21,bg="gray40")
#' nlsTracePlot(fit1,vb1,legend="bottomright")
#' 
#' data(CodNorwegian)
#' r1 <- srFuns("Ricker")
#' fitSR1 <- nls(log(recruits)~log(r1(stock,a,b)),data=CodNorwegian,start=list(a=3,b=0.03))
#' plot(recruits~stock,data=CodNorwegian,pch=21,bg="gray40",xlim=c(0,200))
#' nlsTracePlot(fitSR1,r1)
#' 
#' # no plot, but returns trace results as a matrix
#' ( tmp <- nlsTracePlot(fitSR1,r1,add=FALSE) )
#' 
#' \dontrun{
#' if (require(FSAdata)) {
#'   data(BSkateGB)
#'   wtr <- filterD(BSkateGB,season=="winter")
#'   bh1 <- srFuns()
#'   trc <- capture.output(try(
#'   fitSR1 <- nls(recruits~bh1(spawners,a,b),wtr,
#'                 start=srStarts(recruits~spawners,data=wtr),trace=TRUE)
#'   ))
#'   plot(recruits~spawners,data=wtr,pch=21,bg="gray40")
#'   nlsTracePlot(trc,bh1)
#'   # zoom in on y-axis
#'   plot(recruits~spawners,data=wtr,pch=21,bg="gray40",ylim=c(0.02,0.07))
#'   nlsTracePlot(trc,bh1,legend="top")
#'   # return just the trace results
#'   ( tmp <- nlsTracePlot(trc,bh1,add=FALSE) )
#' }
#' }
#' 
#' @export
nlsTracePlot <- function(object,fun,from=NULL,to=NULL,n=199,
                         lwd=2,pal=paletteChoices(),rev.col=FALSE,
                         legend="topright",cex.leg=0.9,box.lty.leg=0,
                         add=TRUE) {
  ## Checks
  if (!class(object) %in% c("nls","character"))
    STOP("'object' must be from 'nls()' or from 'capture.output()'.")
  fun <- match.fun(fun)
  pal <- match.arg(pal)
  if (n<2) STOP("'n' must be greater than 2.")
  ## Determine if need to capture trace (if object is object from nls())
  if (class(object)=="nls") {
    object <- utils::capture.output( try(tmp <- stats::update(object,.~.,trace=TRUE),silent=TRUE) )
  }
  ## parse trace into a data.frame
  trcDF <- unlist(strsplit(unlist(strsplit(object,":"))," "))
  trcDF <- as.numeric(trcDF[trcDF!=""])
  trcDF <- matrix(trcDF,nrow=length(object),byrow=TRUE)
  ## plot each iteration onto existing plot
  if (add) {
    if (!iPlotExists()) STOP("An active plot does not exist.")
    niter <- nrow(trcDF)
    clrs <- chooseColors(pal,niter,rev.col)
    if (is.null(from)) from <- graphics::par("usr")[1L] # nocov start
    if (is.null(to)) to <- graphics::par("usr")[2L]
    xs <- seq(from,to,length.out=n)
    for (i in 1:niter) {
      ys <- do.call(fun,list(xs,trcDF[i,-1]))
      graphics::lines(xs,ys,lwd=lwd,col=clrs[i])
    }
    ## add legend if asked for
    leg <- iLegendHelp(legend)
    if (leg$do.legend) {
      lbls <- c("start",paste0("end (",niter,")"))
      graphics::legend(x=leg$x,y=leg$y,legend=lbls,
                       col=clrs[c(1,niter)],lwd=lwd,
                       bty="n",cex=cex.leg,box.lty=box.lty.leg)
    } # nocov end
  }
  ## return trace data.frame
  invisible(trcDF)
}