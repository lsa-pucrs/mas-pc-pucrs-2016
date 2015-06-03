{ include("common.asl") }

+chargingStation(Id, Lat, Lng, Rate, Price, Slots)[source(A)]
	: true
<-
	.print("Itz a charger!");
	!goto(Id);
	.

+product(Id, Volume, Info)[source(A)]
	: true
<-
	.print(product(Id, Volume, Info));
	.
