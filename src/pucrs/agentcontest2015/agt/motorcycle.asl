!register.

+inFacility(X)[artifact_id(_)] : going(L) & X == L <- -going(L); +inFacility(X).
@chargingList[atomic]
+chargingStation(X,_,_,_,_,_) :  chargingList(L) & not .member(X,L) <- -+chargingList([X|L]); ?chargingList(Y); .print(Y).

+!select_goal : lowBattery & inFacility(X) & chargingList(L) & .member(X,L) & not charging  <- !charge. 

+!select_goal : charging <- .print("Keep charging."); !continue.
+!select_goal : not going(_) & lowBattery <- .print("Going to charging station 1."); !goto(charging1).
+!select_goal : going(L) <- .print("Continuing to location ",L); !continue.

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.
