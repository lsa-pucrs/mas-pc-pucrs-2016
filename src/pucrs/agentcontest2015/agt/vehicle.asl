{ include("common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-select-goal.asl") }
{ include("end-round.asl") }
{ include("new-round.asl") }
{ include("bidder.asl") }
{ include("props.asl") } // might not be needed when we make the change to obs. prop. in Cartago

+!register(E)
	: true
<-
    .print("Registering...");
    .my_name(Me);
    .concat("eis_art_", Me, ArtName);
    .term2string(Me, MeS);
    makeArtifact(ArtName, "pucrs.agentcontest2015.env.EISArtifact", [MeS, E], AId);
    focus(AId);
	.
	
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
	: not roled(_, _, _, _, _) & jcm__art("puc", "team1", ArtId)
<-
	.print("Got role: ", Role);
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	.lower_case(Role,File);
	adoptRole(File)[artifact_id(ArtId)];
	!new_round(Role, Speed, LoadCap, BatteryCap, Tools);	
	.concat(File, ".asl", FileExt);
	.include(FileExt);
	if (Role == "Truck")
	{
		adoptRole(initiator)[artifact_id(ArtId)];
		.include("initiator.asl");
		!create_taskboard;
	};
	focusWhenAvailable("task_board");
	.print("Task board located.");	
	.
	
+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: not roled(_, _, _, _, _)
<-
	.print("I do not have any plan for role: ", Role);
	.