aic.loss <-
function (pred.obj)
{
## Bemerkung: Das m�ssen wir so umst�ndlich machen, da die hat-matrix bei Boosting-Verfahren anders berechnet wird,
## daher k�nnen wir nicht family$aic verwenden...

   dev <- pred.obj$deviance
   tr.H <- pred.obj$tr.H

   dev + 2 * tr.H
}

