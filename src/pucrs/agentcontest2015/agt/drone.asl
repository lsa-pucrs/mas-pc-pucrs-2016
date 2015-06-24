!register.

+inFacility(X) : going(L) & X == L & not arrived <- +arrived.

+!select_goal : arrived & going(L)  <- .print("Arrived in ",L); -going(L).
+!select_goal : lastStep(X) & going(L) & not arrived <- .print("Continuing to ",L,". At step ",X); !skip.
+!select_goal : lastStep(X) & not going(shop3) & not arrived <- .print("Going to shop3 At step ",X); +going(shop3); !goto(shop3).

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.
