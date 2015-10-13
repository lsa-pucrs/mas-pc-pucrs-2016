//{ include("common-cartago.asl") }
//{ include("$jacamoJar/templates/common-cartago.asl") }
//{ include("$jacamoJar/templates/common-moise.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-select-goal.asl") }
{ include("end-round.asl") }
{ include("new-round.asl") }
{ include("bidder.asl") }

+!register(E)
	: true
<-
    .print("Registering...");
    .my_name(Me);
    .concat("eis_art_", Me, ArtName);
    .term2string(Me, MeS);
    makeArtifact(ArtName, "pucrs.agentcontest2015.env.EISArtifact", [], AId);
    focus(AId);
    register(E);
	.

+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: true
<-
	.print("Got role: ", Role);
	.lower_case(Role,File);
	//adoptRole(File)[artifact_id(ArtId)];
	!new_round;	
	.concat(File, ".asl", FileExt);
	.include(FileExt);
	if (Role == "Truck")
	{
		//adoptRole(initiator)[artifact_id(ArtId)];
		.include("initiator.asl");
		!create_taskboard;
	};
	focusWhenAvailable("task_board");
	.print("Task board located.");	
	.
	
/* 
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
*/	