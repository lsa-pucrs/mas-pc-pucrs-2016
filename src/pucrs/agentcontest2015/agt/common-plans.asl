+step(Step) 
	: roled(_, _, _, _, _)
<-
	.wait({+ok});
 	-+lastStep(Step);
	!select_goal;
	.
	
+simEnd
	: roled(Role, Speed, LoadCap, BatteryCap, Tools) & current_wsp(WSid,WSname,WScode) & jcm__art(WS,Art,ArtId) & jcm__ws(WSname2,WSid2)
<-
	!end_round;
	!new_round(Role, Speed, LoadCap, BatteryCap, Tools);
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	+current_wsp(WSid,WSname,WScode); 
	+jcm__art(WS,Art,ArtId);
	+jcm__ws(WSname2,WSid2);
	.
	
+charge(Battery)
	: charging & chargeTotal(BatteryTotal) & BatteryTotal == Battery
<-
	.print("Stop charging, battery is full.");
	-charging;
	.
	
@shopsList[atomic]
+shop(ShopId, Lat, Lng, Items)
	: shopsList(List) & not .member(shop(ShopId,_),List)
<-
	-+shopsList([shop(ShopId,Items)|List]);
	.
	
@chargingList[atomic]
+chargingStation(ChargingId,Lat,Lng,Rate,Price,Slots) 
	:  chargingList(List) & not .member(ChargingId,List) 
<- 
	-+chargingList([ChargingId|List]);
	.
	
@workshopList[atomic]
+workshop(WorkshopId,Lat,Lng,Price) 
	:  workshopList(List) & not .member(WorkshopId,List) 
<- 
	-+workshopList([WorkshopId|List]);
	.	
	
