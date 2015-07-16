{ include("common-cartago.asl") }
{ include("common-perceptions.asl") }
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
	.wait(100);
	!select_goal;
	.

+role("Drone")
	: not roled
<-
	.print("Got role: Drone");
	pucrs.agentcontest2015.env.include("drone.asl");
	+roled;
	.wait(100);
	!select_goal;
	.

+role("Motorcycle")
	: not roled
<-
	.print("Got role: Motorcycle");
	pucrs.agentcontest2015.env.include("motorcycle.asl");
	+roled;
	.wait(100);
	!select_goal;
	.

+role("Truck")
	: not roled
<-
	.print("Got role: Truck");
	pucrs.agentcontest2015.env.include("truck.asl");
	+roled;
	.wait(100);
	!select_goal;
	.
	
+role(S)
	: not roled
<-
	.print("Wat? Got role: ", S);
	.
	
+charge(X)[artifact_id(_)] <- -+charge(X).
	
+step(X) 
	: true
<-
	.wait(100);
 	-+lastStep(X);
	!select_goal;
	.
