{ include("common.asl") }

!register.

// Why Cartago signals are not stored? :(

+shop(X,Y,Z,H)
	: X == shop3 & not (going(X))
<- +going(X);
	!goto(X).

+inFacility(X)<- +inFacility(X).	
	
+step(S): going(X) & inFacility(X)
<- .print("I am at - ", X).	
	
+step(S): going(X)
<- .print(S);
	!goto(X).

+!continueA(Id)
	: true
<-
	.concat("facility=", Id, Param);
	action("goto", Param)
	.

//+chargingStation(Id, Lat, Lng, Rate, Price, Slots)[source(A)]
//	: true
//<-
//	.print("Itz a charger!");
//	.wait(500);
//	!goto(Id);
//	.
+product(Id, Volume, Info)[source(A)]
	: true
<-
	.print(product(Id, Volume, Info));
	.
