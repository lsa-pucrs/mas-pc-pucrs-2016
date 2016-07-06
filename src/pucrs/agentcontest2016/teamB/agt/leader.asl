{ include("common-cartago.asl") }

!register_leader.

+!register_leader
	: true
<-
	.print("Registering leader...");
	register_leader;
	.

+role(Ag, Role, _, _, _ , _)
	: true
<-
	.print("Agent ", Ag, " get role ", Role);
	.