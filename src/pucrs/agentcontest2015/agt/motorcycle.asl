{ include("common.asl") }

!register.

// Why Cartago signals are not stored? :(

+chargingStation(Id, Lat, Lng, Rate, Price, Slots)[source(A)]
	: true
<-
	.print("Itz a charger!");
	.wait(500);
	!goto(Id);
	.

+product(Id, Volume, Info)[source(A)]
	: true
<-
	.print(product(Id, Volume, Info));
	.
