{ include("common-cartago.asl") }
{ include("common-actions.asl") }

!register_freeconn.

+!register_freeconn
	: true
<-
	.print("Registering...");
	register_freeconn;
	.

+role("Car")
	: true
<-
	pucrs.agentcontest2015.env.include("car.asl");
	.

+role("Drone")
	: true
<-
	pucrs.agentcontest2015.env.include("drone.asl");
	.

+role("Motorcycle")
	: true
<-
	pucrs.agentcontest2015.env.include("motorcycle.asl");
	.

+role("Truck")
	: true
<-
	pucrs.agentcontest2015.env.include("truck.asl");
	.
	
+role(S)
	: true
<-
	.print("Wat? Got role: ", S);
	.