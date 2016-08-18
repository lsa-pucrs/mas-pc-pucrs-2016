{ include("new-round.asl") }
{ include("end-round.asl") }
{ include("common-plans.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("bidder.asl") }
{ include("common-strategies.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }
//{ include("$jacamoJar/templates/common-moise.asl") }

!start.

+!start
	: .my_name(Me)
<-
 	.wait({ +step(_) });
// 	!waitShopList;
// 	!calculateStepsRequiredAllShops;
	if (Me == vehicle1) {
		!start_ringing;		
	}
 	
 	+free;
    .

+!register(E)
	: .my_name(Me)
<-
	!new_round;
	if (Me == vehicle1) {
		makeArtifact("teamArtifact","pucrs.agentcontest2016.env.TeamArtifact",[]);
		+working;
		+max_bid_time(1000);
//		adoptRole(initiator);
		.include("initiator.asl");
		!create_taskboard;
		focusWhenAvailable("teamArtifact");		
	}
	focusWhenAvailable("task_board");
	.print("Task board located.");
    .print("Registering...");
    .concat("eis_art_", Me, ArtName);
    .term2string(Me, MeS);
    makeArtifact(ArtName, "pucrs.agentcontest2016.env.EISArtifact", [], AId);
    focus(AId);
    register(E);
	.

+role(Role, Speed, LoadCap, BatteryCap, Tools)
	: .my_name(Me)
<-
	.print("Got role: ", Role);
	.lower_case(Role,File);
//	adoptRole(File);
	.concat(File, ".asl", FileExt);
	.include(FileExt);
	addLoad(Me,LoadCap);
	.
	
/*
+serverName(Name)[artifact_id(_)]
	: true
<-
	+serverName(Name);
	.print("My server name is ",Name);
.	
*/	