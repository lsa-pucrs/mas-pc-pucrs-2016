{ include("common-cartago.asl") }
{ include("common-perceptions.asl") }
{ include("common-actions.asl") }

!register_freeconn.

+!register_freeconn
	: true
<-
	.print("Registering...");
	register_freeconn;
	.

+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: not roled
<-
	.print("Got role: ", Role);
	pucrs.agentcontest2015.actions.tolower(Role, File);
	.concat(File, ".asl", FileExt);
	pucrs.agentcontest2015.actions.include(FileExt);
	+roled;
	.wait(100);
	!select_goal;
	.
	
+role(S)
	: not roled
<-
	.print("Wat? Got role: ", S);
	.
	
+charge(X)[artifact_id(_)] <- -+charge(X).
	
+step(X) 
	: true
<-
	.wait(100);
 	-+lastStep(X);
	!select_goal;
	.
