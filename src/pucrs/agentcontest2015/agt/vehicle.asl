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
	: not roled
<-
	.print("Got role: Car");
	pucrs.agentcontest2015.env.include("car.asl");
	+roled;
	.

+role("Drone")
	: not roled
<-
	.print("Got role: Drone");
	pucrs.agentcontest2015.env.include("drone.asl");
	+roled;
	.

+role("Motorcycle")
	: not roled
<-
	.print("Got role: Motorcycle");
	pucrs.agentcontest2015.env.include("motorcycle.asl");
	+roled;
	.

+role("Truck")
	: not roled
<-
	.print("Got role: Truck");
	pucrs.agentcontest2015.env.include("truck.asl");
	+roled;
	.
	
+role(S)
	: not roled
<-
	.print("Wat? Got role: ", S);
	.
	
+step(X) 
	: true
<-
 	-+lastStep(X);
	.wait(100);
	!select_goal.