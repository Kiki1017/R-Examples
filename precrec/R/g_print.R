#
# Print mdat
#
#' @export
print.mdat <- function(x, ...) {
  # === Validate input arguments ===
  .validate(x)

  # === print ===
  cat("\n")
  cat("    === Input data ===\n\n")

  data_info <- attr(x, "data_info")
  rownames(data_info) <- format(rownames(data_info), width = 4,
                                justify = "right")
  colnames(data_info) <- c("Model name", "Dataset ID", "# of positives",
                           "# of negatives")

  print.data.frame(data_info, print.gap = 1)

  cat("\n")
}

#
# Print the summary of ROC and Precision-Recall curves
#
#' @export
print.curve_info <- function(x, ...) {
  # === Validate input arguments ===
  .validate(x)

  # === print ===
  cat("\n")
  cat("    === AUCs ===\n")
  cat("\n")

  aucs <- attr(x, "aucs")
  rownames(aucs) <- format(rownames(aucs), width = 4, justify = "right")
  colnames(aucs) <- c("Model name", "Dataset ID", "Curve type", "AUC")

  print.data.frame(aucs, print.gap = 1)
  cat("\n")

  print.mdat(x)
}

#
# Print the summary of basic performance evaluation measures
#
#' @export
print.beval_info <- function(x, ...) {
  # === Validate input arguments ===
  .validate(x)

  # === print ===
  cat("\n")
  cat("    === Basic performance evaluation measures ===\n\n")
  cat("     ## Performance measures (Meas.)\n")
  cat("      rank: threshold rank\n")
  cat("      err:  error rate\n")
  cat("      acc:  accuracy\n")
  cat("      sp:   specificity\n")
  cat("      sn:   sensitivity\n")
  cat("      prec: precision\n")
  cat("\n\n")

  eval_summary <- attr(x, "eval_summary")
  rownames(eval_summary) <- format(rownames(eval_summary), width = 4,
                                   justify = "right")
  colnames(eval_summary) <- c("Model", "ID", "Meas.", "Min.",
                              "1st Qu.", "Median", "Mean", "3rd Qu.", "Max.")
  evaltypes <- c("rank", "err", "acc", "sp", "sn", "prec")
  eval_summary[, "Meas."] <- evaltypes

  print.data.frame(eval_summary, print.gap = 1)
  cat("\n")

  print.mdat(x)
}
