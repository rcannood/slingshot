#' @describeIn newSlingshotDataSet returns a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "newSlingshotDataSet",
    signature = signature("data.frame","ANY"),
    definition = function(reducedDim, clusterLabels, ...){
        RD <- as.matrix(reducedDim)
        rownames(RD) <- rownames(reducedDim)
        if(missing(clusterLabels)){
            message('Unclustered data detected.')
            clusterLabels <- rep('1', nrow(reducedDim))
        }
        newSlingshotDataSet(RD, clusterLabels, ...)
    })
#' @describeIn newSlingshotDataSet returns a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "newSlingshotDataSet",
    signature = signature("matrix", "numeric"),
    definition = function(reducedDim, clusterLabels, ...){
        newSlingshotDataSet(reducedDim, as.character(clusterLabels), ...)
    })
#' @describeIn newSlingshotDataSet returns a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "newSlingshotDataSet",
    signature = signature("matrix","factor"),
    definition = function(reducedDim, clusterLabels, ...){
        newSlingshotDataSet(reducedDim, as.character(clusterLabels), ...)
    })
#' @describeIn newSlingshotDataSet returns a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "newSlingshotDataSet",
    signature = signature("matrix","ANY"),
    definition = function(reducedDim, clusterLabels, ...){
        if(missing(clusterLabels)){
            message('Unclustered data detected.')
            clusterLabels <- rep('1', nrow(reducedDim))
        }
        newSlingshotDataSet(reducedDim, as.character(clusterLabels), ...)
    })
#' @describeIn newSlingshotDataSet returns a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "newSlingshotDataSet",
    signature = signature("matrix","character"),
    definition = function(reducedDim, clusterLabels, ...){
        if(nrow(reducedDim) != length(clusterLabels)) {
            stop('nrow(reducedDim) must equal length(clusterLabels).')
        }
        # something requires row and column names. Princurve?
        if(is.null(rownames(reducedDim))){
            rownames(reducedDim) <- paste('Cell',seq_len(nrow(reducedDim)),
                                          sep='-')
        }
        if(is.null(colnames(reducedDim))){
            colnames(reducedDim) <- paste('Dim',seq_len(ncol(reducedDim)),
                                          sep='-')
        }
        if(is.null(names(clusterLabels))){
            names(clusterLabels) <- rownames(reducedDim)
        }
        clusW <- table(rownames(reducedDim), clusterLabels)
        clusW <- clusW[match(rownames(reducedDim),rownames(clusW)), ,drop=FALSE]
        class(clusW) <- 'matrix'
        return(newSlingshotDataSet(reducedDim, clusW, ...))
    })

#' @describeIn newSlingshotDataSet returns a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "newSlingshotDataSet",
    signature = signature("matrix","matrix"),
    definition = function(reducedDim, clusterLabels, 
                          lineages=list(),
                          adjacency=matrix(NA,0,0),
                          curves=list(),
                          slingParams=list()
    ){
        if(nrow(reducedDim) != nrow(clusterLabels)) {
            stop('nrow(reducedDim) must equal nrow(clusterLabels).')
        }
        # something requires row and column names. Princurve?
        if(is.null(rownames(reducedDim))){
            rownames(reducedDim) <- paste('Cell',seq_len(nrow(reducedDim)),
                                          sep='-')
        }
        if(is.null(colnames(reducedDim))){
            colnames(reducedDim) <- paste('Dim',seq_len(ncol(reducedDim)),
                                          sep='-')
        }
        if(is.null(rownames(clusterLabels))){
            rownames(clusterLabels) <- rownames(reducedDim)
        }
        if(is.null(colnames(clusterLabels))){
            colnames(clusterLabels) <- seq_len(ncol(clusterLabels))
        }
        out <- new("SlingshotDataSet",
                   reducedDim = reducedDim,
                   clusterLabels = clusterLabels,
                   lineages = lineages,
                   adjacency = adjacency,
                   curves = curves,
                   slingParams = slingParams
        )
        return(out)
    })



#' @describeIn SlingshotDataSet a short summary of \code{SlingshotDataSet}
#'   object.
#'   
#' @param object a \code{SlingshotDataSet} object.
#' @export
setMethod(
    f = "show",
    signature = "SlingshotDataSet",
    definition = function(object) {
        cat("class:", class(object), "\n\n")
        df <- data.frame(Samples = nrow(reducedDim(object)), 
                         Dimensions = ncol(reducedDim(object)))
        print(df, row.names = FALSE)
        cat('\nlineages:', length(slingLineages(object)), "\n")
        for(i in seq_len(length(slingLineages(object)))){
            cat('Lineage',i,": ", paste(slingLineages(object)[[i]],' '), "\n", 
                sep='')
        }
        cat('\ncurves:', length(slingCurves(object)), "\n")
        for(i in seq_len(length(slingCurves(object)))){
            cat('Curve',i,": ", "Length: ", 
                signif(max(slingCurves(object)[[i]]$lambda), digits = 5), 
                "\tSamples: ", round(sum(slingCurves(object)[[i]]$w), 
                                     digits = 2), 
                "\n", sep='')
        }
    }
)
# accessor methods
#' @describeIn SlingshotDataSet returns the matrix representing the reduced
#'   dimensional dataset.
#' @param x a \code{SlingshotDataSet} object.
#' @importFrom SingleCellExperiment reducedDim
#' @export
setMethod(
    f = "reducedDim",
    signature = c("SlingshotDataSet", "ANY"),
    definition = function(x) x@reducedDim
)
#' @describeIn SlingshotDataSet returns the matrix representing the reduced
#'   dimensional dataset.
#' @importFrom SingleCellExperiment reducedDims
#' @export
setMethod(
    f = "reducedDims",
    signature = "SlingshotDataSet",
    definition = function(x) x@reducedDim
)
#' @describeIn slingClusterLabels returns the cluster labels stored in a
#'   \code{\link{SlingshotDataSet}} object.
#' @export
setMethod(
    f = "slingClusterLabels",
    signature = signature(x="SlingshotDataSet"),
    definition = function(x){
        return(x@clusterLabels)
    }
)
#' @describeIn slingClusterLabels returns the cluster labels used by
#'   \code{\link{slingshot}} in a \code{\link{SingleCellExperiment}} object.
#' @importClassesFrom SingleCellExperiment SingleCellExperiment
#' @export
setMethod(
    f = "slingClusterLabels",
    signature = "SingleCellExperiment",
    definition = function(x) x@int_metadata$slingshot@clusterLabels
)
#' @describeIn slingAdjacency returns the adjacency matrix between
#'   clusters from a \code{\link{SlingshotDataSet}} object.
#' @export
setMethod(
    f = "slingAdjacency",
    signature = "SlingshotDataSet",
    definition = function(x) x@adjacency
)
#' @describeIn slingAdjacency returns the adjacency matrix between
#'   clusters from a \code{\link{SingleCellExperiment}} object.
#' @importClassesFrom SingleCellExperiment SingleCellExperiment
#' @export
setMethod(
    f = "slingAdjacency",
    signature = "SingleCellExperiment",
    definition = function(x) x@int_metadata$slingshot@adjacency
)

#' @describeIn slingLineages returns the list of lineages, represented by
#'   ordered sets of clusters from a \code{\link{SlingshotDataSet}} object.
#' @export
setMethod(
    f = "slingLineages",
    signature = "SlingshotDataSet",
    definition = function(x) x@lineages
)
#' @describeIn slingLineages returns the list of lineages, represented by 
#'   ordered sets of clusters from a \code{\link{SingleCellExperiment}} object.
#' @export
setMethod(
    f = "slingLineages",
    signature = "SingleCellExperiment",
    definition = function(x) x@int_metadata$slingshot@lineages
)

#' @describeIn slingCurves returns the list of smooth lineage curves from a
#'   \code{\link{SlingshotDataSet}} object.
#' @export
setMethod(
    f = "slingCurves",
    signature = "SlingshotDataSet",
    definition = function(x) x@curves
)
#' @describeIn slingCurves returns the list of smooth lineage curves from a
#'   \code{\link{SingleCellExperiment}} object.
#' @export
setMethod(
    f = "slingCurves",
    signature = "SingleCellExperiment",
    definition = function(x) x@int_metadata$slingshot@curves
)

#' @describeIn slingParams returns the list of additional parameters used
#' by Slingshot from a \code{\link{SlingshotDataSet}} object.
#' @export
setMethod(
    f = "slingParams",
    signature = "SlingshotDataSet",
    definition = function(x) x@slingParams
)
#' @describeIn slingParams returns the list of additional parameters used
#' by Slingshot from a \code{\link{SingleCellExperiment}} object.
#' @export
setMethod(
    f = "slingParams",
    signature = "SingleCellExperiment",
    definition = function(x) x@int_metadata$slingshot@slingParams
)


# replacement methods
# #' @describeIn SlingshotDataSet Updated object with new reduced dimensional
# #'   matrix.
# #' @param value matrix, the new reduced dimensional dataset.
# #' 
# #' @details 
# #' Warning: this will remove any existing lineages or curves from the 
# #' \code{SlingshotDataSet} object.
# #' @importFrom SingleCellExperiment reducedDim<-
# #' @export
# setReplaceMethod(
#     f = "reducedDim",
#     signature = "SlingshotDataSet",
#     definition = function(x, value) initialize(x, reducedDim = value,
#                                          clusterLabels = clusterLabels(x)))
# 
#' # replacement methods
# #' @describeIn SlingshotDataSet Updated object with new reduced dimensional
# #'   matrix.
# #' @param value matrix, the new reduced dimensional dataset.
# #' 
# #' @details 
# #' Warning: this will remove any existing lineages or curves from the 
# #' \code{SlingshotDataSet} object.
# #' @importFrom SingleCellExperiment reducedDims<-
# #' @export
# setReplaceMethod(
#     f = "reducedDims",
#     signature = "SlingshotDataSet",
#     definition = function(x, value) initialize(x, reducedDim = value,
#                                          clusterLabels = clusterLabels(x)))
# 
# #' @describeIn SlingshotDataSet Updated object with new vector of cluster
# #'   labels.
# #' @param value character, the new vector of cluster labels.
# #' 
# #' @details 
# #' Warning: this will remove any existing lineages or curves from the 
# #' \code{SlingshotDataSet} object.
# #' @export
# setReplaceMethod(
#     f = "clusterLabels",
#     signature = c(object = "SlingshotDataSet", value = "ANY"),
#     definition = function(object, value) initialize(x,
#                                                reducedDim = reducedDim(x),
#                                                clusterLabels = value))

#' @describeIn SlingshotDataSet Subset dataset and cluster labels.
#' @param i indices to be applied to rows (cells) of the reduced dimensional
#' matrix and cluster labels.
#' @param j indices to be applied to the columns (dimensions) of the reduced
#' dimensional matrix.
#' @details 
#' Warning: this will remove any existing lineages or curves from the 
#' \code{SlingshotDataSet} object.
#' @export
setMethod(f = "[", 
          signature = c("SlingshotDataSet", "ANY", "ANY", "ANY"),
          function(x, i, j)
          {
              rd <- reducedDim(x)[i,j, drop=FALSE]
              cl <- slingClusterLabels(x)[i, , drop=FALSE]
              initialize(x, reducedDim = rd,
                         clusterLabels  = cl,
                         lineages = list(),
                         adjacency = matrix(NA,0,0),
                         curves = list(),
                         slingParams = slingParams(x))
          })


#' @describeIn slingPseudotime returns the matrix of pseudotime values from a
#'   \code{\link{SlingshotDataSet}} object.
#' @param na logical. If \code{TRUE} (default), cells that are not assigned to a
#'   lineage will have a pseudotime value of \code{NA}. Otherwise, their
#'   arclength along each curve will be returned.
#' @export
setMethod(
    f = "slingPseudotime",
    signature = "SlingshotDataSet",
    definition = function(x, na = TRUE){
        if(length(slingCurves(x))==0){
            stop('No curves detected.')
        }
        pst <- vapply(slingCurves(x), function(pc) {
            t <- pc$lambda
            if(na){
                t[pc$w == 0] <- NA
            }
            return(t)
        }, rep(0,nrow(reducedDim(x))))
        rownames(pst) <- rownames(reducedDim(x))
        colnames(pst) <- names(slingCurves(x))
        return(pst)
    }
)
#' @describeIn slingPseudotime returns the matrix of pseudotime values from a
#'   \code{\link{SingleCellExperiment}} object.
#' @export
setMethod(
    f = "slingPseudotime",
    signature = "SingleCellExperiment",
    definition = function(x, na = TRUE){
        return(slingPseudotime(x@int_metadata$slingshot))
    }
)

#' @describeIn slingPseudotime returns the matrix of cell weights along each
#'   lineage from a \code{\link{SlingshotDataSet}} object.
#' @param as.probs logical. If \code{FALSE} (default), output will be the
#'   weights used to construct the curves, appropriate for downstream analysis
#'   of individual lineages (ie. a cell shared between two lineages can have two
#'   weights of \code{1}). If \code{TRUE}, output will be scaled to represent
#'   probabilistic assignment of cells to lineages (ie. a cell shared between
#'   two lineages will have two weights that sum to \code{1}).
#' @export
setMethod(
    f = "slingCurveWeights",
    signature = "SlingshotDataSet",
    definition = function(x, as.probs = FALSE){
        if(length(slingCurves(x))==0){
            stop('No curves detected.')
        }
        weights <- vapply(slingCurves(x), function(pc) { pc$w },
            rep(0, nrow(reducedDim(x))))
        rownames(weights) <- rownames(reducedDim(x))
        colnames(weights) <- names(slingCurves(x))
        if(as.probs){
            weights <- weights / rowSums(weights)
        }
        return(weights)
    }
)
#' @describeIn slingPseudotime returns the matrix of cell weights along each
#'   lineage from a \code{\link{SingleCellExperiment}} object.
#' @export
setMethod(
    f = "slingCurveWeights",
    signature = "SingleCellExperiment",
    definition = function(x){
        return(slingCurveWeights(x@int_metadata$slingshot))
    }
)

#' @rdname SlingshotDataSet
#' @export
setMethod(
    f = "SlingshotDataSet",
    signature = "SingleCellExperiment",
    definition = function(data){
        if(! "slingshot" %in% names(data@int_metadata)){
            stop('No slingshot results found.')
        }
        return(data@int_metadata$slingshot)
    }
)

#' @rdname SlingshotDataSet
#' @export
setMethod(
  f = "SlingshotDataSet",
  signature = "SlingshotDataSet",
  definition = function(data){
    return(data)
  }
)



##########################
### Internal functions ###
##########################
#' @import stats
#' @import graphics
`.slingParams<-` <- function(x, value) {
    x@slingParams <- value
    x
}
`.slingCurves<-` <- function(x, value) {
    x@curves <- value
    x
}
# to avoid confusion between the clusterLabels argument and function
.getClusterLabels <- function(x){
    x@clusterLabels
}
.scaleAB <- function(x,a=0,b=1){
    ((x-min(x,na.rm=TRUE))/(max(x,na.rm=TRUE)-min(x,na.rm=TRUE)))*(b-a)+a
}
.avg_curves <- function(pcurves, X, stretch = 2, approx_points = FALSE){
    n <- nrow(pcurves[[1]]$s)
    p <- ncol(pcurves[[1]]$s)
    max.shared.lambda <- min(vapply(pcurves, function(pcv){max(pcv$lambda)},0))
    lambdas.combine <- seq(0, max.shared.lambda, length.out = n)
    
    pcurves.dense <- lapply(pcurves,function(pcv){
        vapply(seq_len(p),function(jj){
            if(approx_points > 0){
                xin_lambda <- seq(min(pcv$lambda), max(pcv$lambda),
                                  length.out = approx_points)
            }else{
                xin_lambda <- pcv$lambda
            }
            interpolated <- approx(xin_lambda[pcv$ord], 
                                   pcv$s[pcv$ord, jj, drop = FALSE],
                                   xout = lambdas.combine, ties = 'ordered')$y
            return(interpolated)
        }, rep(0,n))
    })
    
    avg <- vapply(seq_len(p),function(jj){
        dim.all <- vapply(seq_along(pcurves.dense),function(i){
            pcurves.dense[[i]][,jj]
        }, rep(0,n))
        return(rowMeans(dim.all))
    }, rep(0,n))
    avg.curve <- project_to_curve(X, avg, stretch=stretch)
    
    if(approx_points > 0){
        xout_lambda <- seq(min(avg.curve$lambda),
                         max(avg.curve$lambda),
                         length.out = approx_points)
        avg.curve$s <- apply(avg.curve$s, 2, function(sjj){
            return(approx(x = avg.curve$lambda[avg.curve$ord],
                          y = sjj[avg.curve$ord], 
                          xout = xout_lambda, ties = 'ordered')$y)
        })
        avg.curve$ord <- seq_len(approx_points)
    }
    
    avg.curve$w <- rowSums(vapply(pcurves, function(p){ p$w }, rep(0,nrow(X))))
    return(avg.curve)
}
# export?
#' @import matrixStats
.dist_clusters_full <- function(X, w1, w2){
    if(length(w1) != nrow(X) | length(w2) != nrow(X)){
        stop("Reduced dimensional matrix and weights vector contain different
             numbers of points.")
    }
    mu1 <- colWeightedMeans(X, w = w1)
    mu2 <- colWeightedMeans(X, w = w2)
    diff <- mu1 - mu2
    s1 <- cov.wt(X, wt = w1)$cov
    s2 <- cov.wt(X, wt = w2)$cov
    return(as.numeric(t(diff) %*% solve(s1 + s2) %*% diff))
}
# export?
.dist_clusters_diag <- function(X, w1, w2){
    if(length(w1) != nrow(X) | length(w2) != nrow(X)){
        stop("Reduced dimensional matrix and weights vector contain different
             numbers of points.")
    }
    mu1 <- colWeightedMeans(X, w = w1)
    mu2 <- colWeightedMeans(X, w = w2)
    diff <- mu1 - mu2
    if(sum(w1>0)==1){
        s1 <-  diag(ncol(X))
    }else{
        s1 <- diag(diag(cov.wt(X, wt = w1)$cov))
    }
    if(sum(w2>0)==1){
        s2 <-  diag(ncol(X))
    }else{
        s2 <- diag(diag(cov.wt(X, wt = w2)$cov))
    }
    return(as.numeric(t(diff) %*% solve(s1 + s2) %*% diff))
}
.cumMin <- function(x,time){
    vapply(seq_along(x),function(i){ min(x[time <= time[i]]) }, 0)
}
.percent_shrinkage <- function(crv, share.idx, approx_points = FALSE,
                               method = 'cosine'){
    pst <- crv$lambda
    if(approx_points > 0){
        pts2wt <- seq(min(crv$lambda), max(crv$lambda),
                      length.out = approx_points)
    }else{
        pts2wt <- pst
    }
    if(method %in% eval(formals(density.default)$kernel)){
        dens <- density(0, bw=1, kernel = method)
        surv <- list(x = dens$x, y = (sum(dens$y) - cumsum(dens$y))/sum(dens$y))
        box.vals <- boxplot(pst[share.idx], plot = FALSE)$stats
        surv$x <- .scaleAB(surv$x, a = box.vals[1], b = box.vals[5])
        if(box.vals[1]==box.vals[5]){
            pct.l <- rep(0, length(pst))
        }else{
            pct.l <- approx(surv$x, surv$y, pts2wt, rule = 2,
                            ties = 'ordered')$y
        }
    }
    if(method == 'tricube'){
        tc <- function(x){ ifelse(abs(x) <= 1, (70/81)*((1-abs(x)^3)^3), 0) }
        dens <- list(x = seq(-3,3,length.out = 512))
        dens$y <- tc(dens$x)
        surv <- list(x = dens$x, y = (sum(dens$y) - cumsum(dens$y))/sum(dens$y))
        box.vals <- boxplot(pst[share.idx], plot = FALSE)$stats
        surv$x <- .scaleAB(surv$x, a = box.vals[1], b = box.vals[5])
        if(box.vals[1]==box.vals[5]){
            pct.l <- rep(0, length(pst))
        }else{
            pct.l <- approx(surv$x, surv$y, pts2wt, rule = 2,
                            ties = 'ordered')$y
        }
    }
    if(method == 'density'){
        bw1 <- bw.SJ(pst)
        bw2 <- bw.SJ(pst[share.idx])
        bw <- (bw1 + bw2) / 2
        d2 <- density(pst[share.idx], bw = bw, 
                      weights = crv$w[share.idx]/sum(crv$w[share.idx]))
        d1 <- density(pst, bw = bw, weights = crv$w/sum(crv$w))
        scale <- sum(crv$w[share.idx]) / sum(crv$w)
        pct.l <- (approx(d2$x,d2$y,xout = pts2wt, yleft = 0, 
                         yright = 0, ties = mean)$y * scale) / 
            approx(d1$x,d1$y,xout = pts2wt, yleft = 0, yright = 0,
                   ties = mean)$y
        pct.l[is.na(pct.l)] <- 0
        pct.l <- .cumMin(pct.l, pts2wt)
    }
    return(pct.l)
}
.shrink_to_avg <- function(pcurve, avg.curve, pct, X, approx_points = FALSE,
                           stretch = 2){
    n <- nrow(pcurve$s)
    p <- ncol(pcurve$s)
    
    if(approx_points > 0){
        lam <- seq(min(pcurve$lambda), max(pcurve$lambda),
                      length.out = approx_points)
        avlam <- seq(min(avg.curve$lambda), max(avg.curve$lambda),
                     length.out = approx_points)
    }else{
        lam <- pcurve$lambda
        avlam <- avg.curve$lambda
    }
    
    s <- vapply(seq_len(p),function(jj){
        orig.jj <- pcurve$s[,jj]
        avg.jj <- approx(x = avlam, y = avg.curve$s[,jj], xout = lam,
                         rule = 2, ties = mean)$y
        return(avg.jj * pct + orig.jj * (1-pct))
    }, rep(0,n))
    w <- pcurve$w
    pcurve <- project_to_curve(X, as.matrix(s[pcurve$ord, ,drop = FALSE]), 
        stretch = stretch)
    pcurve$w <- w
    
    if(approx_points > 0){
      xout_lambda <- seq(min(pcurve$lambda), max(pcurve$lambda),
                         length.out = approx_points)
      pcurve$s <- apply(pcurve$s, 2, function(sjj){
        return(approx(x = pcurve$lambda[pcurve$ord],
                      y = sjj[pcurve$ord], 
                      xout = xout_lambda, ties = 'ordered')$y)
      })
      pcurve$ord <- seq_len(approx_points)
    }
    return(pcurve)
}


################
### Datasets ###
################

#' @title Bifurcating lineages data
#' @name slingshotExample
#' @aliases slingshotExample rd cl
#'   
#' @description This simulated dataset contains a low-dimensional representation
#'   of two bifurcating lineages (\code{rd}) and a vector of cluster labels
#'   generated by k-means with \code{K = 5} (\code{cl}).
#'   
#' @format \code{rd} is a matrix of coordinates in two dimensions, representing
#'   140 cells. \code{cl} is a numeric vector of 140 corresponding cluster
#'   labels for each cell.
#' @source Simulated data provided with the \code{slingshot} package.
#' 
#' @examples 
#' data("slingshotExample")
#' slingshot(rd, cl)
"rd"

#' @rdname slingshotExample
"cl"
