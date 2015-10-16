{ include("common-cartago.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-select-goal.asl") }
{ include("end-round.asl") }
{ include("new-round.asl") }
{ include("bidder.asl") }
{ include("props.asl") }           // might not be needed when we make the change to obs. prop. in Cartago

+!register(E)
	: true
<-
    .print("Registering...");
    register(E);
	.

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
	pucrs.agentcontest2015.teamB.actions.tolower(Role, File);
	.concat(File, ".asl", FileExt);
	pucrs.agentcontest2015.teamB.actions.include(FileExt);
	if (Role == "Truck")
	{
		pucrs.agentcontest2015.teamB.actions.include("initiator.asl");
		!create_taskboard;
	};
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	focusWhenAvailable("task_board");
	.print("Task board located.");	
	.
	
+role(Role)
	: not roled(_, _, _, _, _)
<-
	.print("I do not have any plan for role: ", Role);
	.