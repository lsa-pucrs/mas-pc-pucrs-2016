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
	: not roled(_, _, _, _, _)
<-
	.print("Got role: ", Role);
	+tools(Tools);
	pucrs.agentcontest2015.actions.tolower(Role, File);
	.concat(File, ".asl", FileExt);
	pucrs.agentcontest2015.actions.include(FileExt);
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	//.wait({+ok});
	//!select_goal;
	.
	
+role(Role)
	: not roled(_, _, _, _, _)
<-
	.print("Wat? Got role: ", Role);
	.
	
+charge(Battery)[artifact_id(_)] <- -+charge(Battery).
	
+step(Step) 
	: roled(_, _, _, _, _)
<-
	.wait({+ok});
 	-+lastStep(Step);
	!select_goal;
	.
