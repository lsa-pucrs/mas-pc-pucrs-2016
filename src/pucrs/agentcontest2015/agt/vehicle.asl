{ include("common-cartago.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-select-goal.asl") }
{ include("end-round.asl") }
{ include("new-round.asl") }
{ include("props.asl") }           // might not be needed when we make the change to obs. prop. in Cartago

!register_freeconn.

+!register_freeconn
	: true
<-
	.print("Registering...");
	register_freeconn;
	.
	
+serverName(Name)[artifact_id(_)]
	: true
<-
	+serverName(Name);
	.print("My server name is ",Name);
.	

+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: not roled(_, _, _, _, _) & .my_name(N)
<-
	.print("Got role: ", Role);
	!new_round(Role, Speed, LoadCap, BatteryCap, Tools);
	pucrs.agentcontest2015.actions.tolower(Role, File);
	.concat(File, ".asl", FileExt);
	pucrs.agentcontest2015.actions.include(FileExt);
	if (N == vehicle1)
	{
		pucrs.agentcontest2015.actions.include("initiator.asl");
		!test;
	};
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	.
	
+role(Role)
	: not roled(_, _, _, _, _)
<-
	.print("I do not have any plan for role: ", Role);
	.