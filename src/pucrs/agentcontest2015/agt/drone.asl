!register.

//+!select_goal : arrived & going  <- .print("Arrived in my objective.").
//+!select_goal : lastStep(X) & going & not arrived <- .print("Continuing my previous action "); !continue.
//+!select_goal : lastStep(X) & not going & not arrived <- .print("Going to shop3 At step ",X); +going(shop3); !goto(shop3).

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.
