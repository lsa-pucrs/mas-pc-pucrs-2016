{ include("common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-select-goal.asl") }
{ include("end-round.asl") }
{ include("new-round.asl") }
{ include("bidder.asl") }
{ include("props.asl") }           // might not be needed when we make the change to obs. prop. in Cartago

!register_freeconn.

+!register_freeconn
	: jcm__art(WorkspaceName, "eis", ArtId)
<-
	.print("Registering...");
	register_freeconn[artifact_id(ArtId)];
	.
	
+serverName(Name)[artifact_id(_)]
	: true
<-
	+serverName(Name);
	.print("My server name is ",Name);
.	

+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: not roled(_, _, _, _, _) & jcm__art(WorkspaceName, "team1", ArtId)
<-
	.print("Got role: ", Role);
	pucrs.agentcontest2015.actions.tolower(Role, File);
	adoptRole(File)[artifact_id(ArtId)];
	!new_round(Role, Speed, LoadCap, BatteryCap, Tools);	
	.concat(File, ".asl", FileExt);
	pucrs.agentcontest2015.actions.include(FileExt);
	if (Role == "Truck")
	{
		adoptRole(initiator)[artifact_id(ArtId)];
		pucrs.agentcontest2015.actions.include("initiator.asl");
		!create_taskboard;
	};
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	focusWhenAvailable("task_board");
	.print("Task board located.");	
	.
	
+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: not roled(_, _, _, _, _)
<-
	.print("I do not have any plan for role: ", Role);
	.