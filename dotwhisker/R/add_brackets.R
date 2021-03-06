#' Add Labelled Brackets to Group Predictors in a Dot-and-Whisker Plot
#'
#' \code{add_brackets} draws brackets along the y-axis beyond the plotting area of a dot-and-whisker plot generated by \code{dwplot}, useful for labelling groups of predictors
#'
#' @param p A dot-and-whisker plot generated by \code{dwplot}.
#' @param brackets A list of brackets; each element of the list should be a character vector consisting of (1) a label for the bracket, (2) the name of the topmost variable to be enclosed by the bracket, and (3) the name of the bottommost variable to be enclosed by the bracket.
#' @param face A typeface for the bracket labels; options are "plain", "bold", "italic", "oblique", and "bold.italic".
#'
#' @return The function returns a \code{gtable} object, which are viewed with \code{\link[gridExtra]{grid.arrange}}.
#'
#' To save, wrap the \code{grid.arrange} command with \code{\link[ggplot2]{ggsave}}.
#'
#' @examples
#' library(broom)
#' library(dplyr)
#'
#' data(mtcars)
#' m1 <- lm(mpg ~ wt + cyl + disp, data = mtcars)
#' m1_df <- broom::tidy(m1) # create data.frame of regression results
#'
#' p <- dwplot(m1_df) +
#'     scale_y_discrete(breaks = 4:1, labels=c("Intercept", "Weight", "Cylinders", "Displacement")) +
#'     theme_bw() + xlab("Coefficient") + ylab("") +
#'     geom_vline(xintercept = 0, colour = "grey50", linetype = 2) +
#'     theme(legend.position="none")
#'
#' two_brackets <- list(c("Engine", "cyl", "disp"), c("Not Engine", "(Intercept)", "wt"))
#'
#' g <- p %>% add_brackets(two_brackets)
#'
#' gridExtra::grid.arrange(g)  # to display
#'
#' # to save (not run)
#' #ggsave(file = "gridplot.pdf", g)
#'
#' @import gtable dplyr
#' @importFrom grid textGrob linesGrob gpar
#'
#' @export

add_brackets <- function(p, brackets, face="italic") {
  pd <- p$data
  y_ind <- NULL # not functional, just for CRAN check
  overhang <- max(pd$y_ind)/40
  overhang <- ifelse(overhang>.4, .4, overhang)
  p1 <- p + theme(plot.margin = unit(c(1, 1, 1, -1), "lines")) + ylab("")

  if (!is.list(brackets)) stop('Error: argument "brackets" is not a list')

  draw_bracket_label <- function(x, f = face) {
      v1 <- pd$y_ind[which(unique(pd$term)==x[2])]
      v2 <- pd$y_ind[which(unique(pd$term)==x[3])]
      top <- max(v1, v2)
      bottom <- min(v1, v2)
      annotation_custom(
          grob = textGrob(label = x[1], gp = gpar(cex = .7, fontface = f), rot = 90),
          ymin = (top+bottom)/2, ymax = (top+bottom)/2,
          xmin = .3, xmax = .3)
  }

  draw_bracket_vert <- function(x, oh = overhang) {
      v1 <- pd$y_ind[which(unique(pd$term)==x[2])]
      v2 <- pd$y_ind[which(unique(pd$term)==x[3])]
      top <- max(v1, v2)
      bottom <- min(v1, v2)
      annotation_custom(grob = linesGrob(), xmin = .6, xmax = .6, ymin = bottom-oh, ymax = top+oh)
  }

  draw_bracket_top <- function(x, oh = overhang) {
      v1 <- pd$y_ind[which(unique(pd$term)==x[2])]
      v2 <- pd$y_ind[which(unique(pd$term)==x[3])]
      top <- max(v1, v2)
      annotation_custom(grob = linesGrob(), xmin = .6, xmax = 1, ymin = top+oh, ymax = top+oh)
  }

  draw_bracket_bottom <- function(x, oh = overhang) {
      v1 <- pd$y_ind[which(unique(pd$term)==x[2])]
      v2 <- pd$y_ind[which(unique(pd$term)==x[3])]
      bottom <- min(v1, v2)
      annotation_custom(grob = linesGrob(), xmin = .6, xmax = 1, ymin = bottom-oh, ymax = bottom-oh)
  }

  theme_p2 <- theme_bw()
  theme_p2$line <- element_blank()
  theme_p2$rect <- element_blank()


  n_vars <- length(unique(p$data$term))
  p2 <- ggplot(p$data, aes(x = -1, y = y_ind)) + geom_point() +
      coord_cartesian(ylim = c(.5, n_vars+.5), xlim = c(0, 1)) +
      xlab(p$labels$x) + ylab("") + theme_p2 +
      theme(plot.margin = unit(c(1, -.5, 1, 0), "lines")) +
      scale_x_continuous(expand = c(0,0))

  for (i in seq(length(brackets))) {
      p2 <- p2 +
          draw_bracket_label(brackets[[i]]) +
          draw_bracket_vert(brackets[[i]]) +
          draw_bracket_top(brackets[[i]]) +
          draw_bracket_bottom(brackets[[i]])
  }

  g1 <- gtable_add_cols(ggplotGrob(p1), unit(1, "cm"), 0)
  g1[["layout"]]$l[g1[["layout"]]$name=="background"] <- 1
  g2 <- gtable_filter(ggplotGrob(p2), pattern = "panel")

  g <- gtable_add_grob(g1, g2, g1[["layout"]]$t[g1[["layout"]]$name=="panel"], 1)
  g <- gtable_add_cols(g, unit(.7, "line"), 0)
  g[["layout"]]$l[g[["layout"]]$name=="background"] <- 1

  return(g)
}
