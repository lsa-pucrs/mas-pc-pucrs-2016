{ include("common-cartago.asl") }

+?eis(ArtId): true <- lookupArtifact("eis", ArtId).

+!register
	: true
<-
	.print("Registering...");
	register;
	.

+!goto(Id)
	: true
<-
	.concat("facility=", Id, Param);
	action("goto", Param);
	.