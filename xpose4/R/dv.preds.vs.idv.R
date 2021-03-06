# Xpose 4
# An R-based population pharmacokinetic/
# pharmacodynamic model building aid for NONMEM.
# Copyright (C) 1998-2004 E. Niclas Jonsson and Mats Karlsson.
# Copyright (C) 2005-2008 Andrew C. Hooker, Justin J. Wilkins, 
# Mats O. Karlsson and E. Niclas Jonsson.
# Copyright (C) 2009-2010 Andrew C. Hooker, Mats O. Karlsson and 
# E. Niclas Jonsson.

# This file is a part of Xpose 4.
# Xpose 4 is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with this program.  A copy can be cound in the R installation
# directory under \share\licenses. If not, see http://www.gnu.org/licenses/.

"dv.preds.vs.idv" <-
  function(object,
           #main = NULL,
           ylb  = "Observations/Predictions",
           #xlb  = xlabel(xvardef("idv",object),object),
           layout=c(3,1),
           #subset = xsubset(object), 
           #onlyfirst = FALSE,
           #inclZeroWRES = FALSE,
           smooth=TRUE,
           scales=list(),
           ...) 
  
{

    ## Make sure we have the necessary variables defined in the 
    ## object.                                                  
    if(is.null(check.vars(c("id","idv","dv","pred","ipred"),object))) {
      return(NULL)
    }


    if(is.null(scales$x$relation)) scales$x$relation="same"
    
    xplot <- xpose.plot.default(xvardef("idv",object),
                                c(xvardef("dv",object),
                                  xvardef("ipred",object),
                                  xvardef("pred",object)),
                                object,
                                scales=scales,
                                #xlb=xlb,
                                ylb=ylb,
                                #main=main,
                                layout=layout,
                                #abline=abline,
                                #lmline=lmline,
                                #subset=subset,
                                smooth=smooth,
                                ...)
        
    return(xplot)

  }

