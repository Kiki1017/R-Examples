#' Calculate distance, velocity, and acceleration.
#' 
#' Calculate distance traveled, velocity, and acceleration for each logged 
#' position. Distance is calculated as the Euclidean distance between successive
#' coordinates, and velocity as distance covered per time interval. The 
#' acceleration denotes the difference in velocity, again normalized per time.
#' 
#' Distances, velocities and acceleration are computed as follows:
#' 
#' The first entry in each respective vector is always zero. Each subsequent 
#' entry thus represents the Euclidean distance traveled since the previous 
#' recorded set of coordinates and the velocity with which the movement between 
#' both samples took place. Thus, both distance and velocity represent the 
#' intervening period between the previous sample and the one with which the 
#' numeric value is saved.
#' 
#' The acceleration, by contrast, denotes the change in velocity between two 
#' adjacent periods. Because of this, it is shifted forward to best match the 
#' actual time point at which the acceleration was measured. Because there will 
#' always be one less value computed for acceleration than for velocity, the 
#' final value in the acceleration vector has been padded with an NA. To 
#' reconstruct the velocity from the acceleration, multiply the acceleration 
#' vector with the sampling interval, compute the cumulative sum of the result, 
#' and add a zero at the beginning.
#' 
#' If the distance is calculated across both horizontal and vertical (x and y) 
#' dimensions, velocity is always positive (or 0). If only one dimension is 
#' used, increases in x (or y) values result in positive velocity, decreases in 
#' negative velocity.
#' 
#' @param data a mousetrap data object created using one of the mt_import 
#'   functions (see \link{mt_example} for details).
#' @param use a character string specifying which trajectory data should be used
#'   (defaults to 'trajectories')
#' @param save_as a character string specifying where the resulting trajectory 
#'   data should be stored.
#' @param dimension a character string specifying across which dimension(s) 
#'   distances, velocity, and acceleration are calculated. By default ("xypos"),
#'   they are calculated across both x and y dimensions. Alternatively, only the
#'   x- ("xpos") or the y- ("ypos") dimension can be used.
#' @param acc_on_abs_vel logical indicating if acceleration should be calculated
#'   based on absolute velocity values (ignoring direction). Only relevant if 
#'   velocity can be negative (see Details).
#' @param show_progress logical indicating whether function should report its 
#'   progress.
#'   
#' @return A mousetrap data object (see \link{mt_example}) with 
#'   Euclidian distance, velocity, and acceleration added as additional columns 
#'   to the trajectory array.
#'   
#' @seealso \link{mt_average} for averaging trajectories across constant time
#' intervals.
#' 
#' \link{mt_calculate_measures} for calculating per-trial mouse-tracking
#' measures.
#' 
#' @examples
#' # Calculate derivatives looking at movement
#' # across both dimensions
#' mt_example <- mt_calculate_derivatives(mt_example)
#' 
#' # Calculate derivatives ony looking at movement
#' # in x dimension
#' mt_example <- mt_calculate_derivatives(mt_example,
#'   dimension="xpos")
#'   
#' @export
mt_calculate_derivatives <- function(data,
  use="trajectories", save_as=use,
  dimension="xypos", acc_on_abs_vel=FALSE,
  show_progress=TRUE) {
  
  # Extract trajectories and labels
  trajectories <- extract_data(data=data,use=use)
  timestamps <- mt_variable_labels[["timestamps"]]
  xpos <- mt_variable_labels[["xpos"]]
  ypos <- mt_variable_labels[["ypos"]]
  dist <- mt_variable_labels[["dist"]]
  vel  <- mt_variable_labels[["vel"]]
  acc  <- mt_variable_labels[["acc"]]
  
  # Remove potentially existing derivates in original data
  trajectories <- trajectories[
    ,
    !dimnames(trajectories)[[2]] %in% c(dist,vel,acc),
    , drop=FALSE]
  
  # Setup new array
  derivatives <- array(
    dim=dim(trajectories) + c(0, 3, 0),
    dimnames=list(
      dimnames(trajectories)[[1]],
      c(
        dimnames(trajectories)[[2]],
        dist, vel, acc
      ),
      dimnames(trajectories)[[3]]
    )
  )
  
  #  Fill it with existing data
  derivatives[,dimnames(trajectories)[[2]],] <- trajectories[,dimnames(trajectories)[[2]],]
  
  # Calculate derivatives
  for (i in 1:nrow(trajectories)){
    
    # Compute deltas for all available data
    # (x & y positions and timestamps)
    delta_timestamps <- diff(derivatives[i,timestamps,])
    delta_xpos <- diff(derivatives[i,xpos,])
    delta_ypos <- diff(derivatives[i,ypos,])
    
    if (dimension == "xypos") {
      # Compute Eucledian distance between measurements 
      # if both x and y dimension should be used
      distances <- sqrt(delta_xpos^2 + delta_ypos^2)
    } else if (dimension == "xpos") {
      # Otherwise simply compute the distance
      distances <- delta_xpos
    } else if (dimension == "ypos") {
      distances <- delta_ypos
    } else {
      stop("dimension argument can only be one of the following: xypos, xpos, ypos")
    }
    
    # Compute velocity based on distance and time deltas
    velocities <- distances / delta_timestamps
    
    # Compute acceleration based on the velocity differences
    if (acc_on_abs_vel) {
      accelerations <- diff(abs(velocities)) / delta_timestamps[-length(delta_timestamps)]
    } else {
      accelerations <- diff(velocities) / delta_timestamps[-length(delta_timestamps)]
    }

    # Pad the accelerations so that they can be concatenated to the remaining data
    accelerations <- c(accelerations, NA)
    
    # Add derivatives to array (adding a ceiling so they have the same length)
    derivatives[i,dist,] <- c(0, distances)
    derivatives[i,vel,] <- c(0, velocities)
    derivatives[i,acc,] <- c(0, accelerations)
    
    if (show_progress){
      if (i %% 100 == 0) message(paste(i,"trials finished"))
    }
  }
  
  if (show_progress){
    message(paste("all",i,"trials finished"))
  }
  
  # Add array to data
  data[[save_as]] <- derivatives

  return(data)
}
