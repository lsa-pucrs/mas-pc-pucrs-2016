{ include("common.asl") }

!register.

// Why Cartago signals are not stored? :(

+shop(X,Y,Z,H)
	: X == shop1
<- 
	!goto(X);
	.print(X)
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
