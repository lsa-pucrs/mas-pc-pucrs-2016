{ include("common-cartago.asl") }
{ include("common-actions.asl") }

!register.
	
+!register
	: true
<-
	.print("Registering...");
	register;
	.