+step(Step) 
	: roled(_, _, _, _, _)
<-
	.wait({+ok});
 	-+lastStep(Step);
	!select_goal;
	.

//+availableItems(ShopId,ItemsInformation)
//  <- println("I perceived a pin for ", ShopId, ", and its available items are: ", ItemsInformation).

+simEnd
	: roled(Role, Speed, LoadCap, BatteryCap, Tools) & current_wsp(WSid,WSname,WScode) & jcm__art(WS,Art,ArtId) & jcm__ws(WSname2,WSid2) & serverName(ServerName)
<-
	!end_round;
	!new_round(Role, Speed, LoadCap, BatteryCap, Tools);
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	+serverName(ServerName);	
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
	
+lastAction(Action)
	: Action \== skip & free
<-
	.print("I am not free anymore.");
	-free;
	.

+lastAction(Action)
	: Action == skip & not free
<-
	.print("I am free.");
	+free;
	.	
	
+helpAssemble(ItemId,Qty,Tool,Facility,Agent)
	: item(Tool,1) & free & not working(_,_,_)
<-
	+helping;
	+warnAgent;
	.print("I can help, I have ",Tool);
	.

+helpAssemble(ItemId,Qty,Tool,Facility,Agent)[source(X)]
	: true
<-
	-helpAssemble(ItemId,Qty,Tool,Facility,Agent)[source(X)];
	.

-helpAssemble(ItemId,Qty,Tool,Facility,Agent)[source(X)]
	: helping & going(Facility)
<-
	+abort;
	.	
	
-helpAssemble(ItemId,Qty,Tool,Facility,Agent)[source(X)]
	: helping
<-
	-helping;
	.		
	
+iAmHere[source(X)]
	: true
<-	
	-waitingForAssistAssemble;
	.		

@shopsList[atomic]
+shop(ShopId, Lat, Lng, Items)
	: shopsList(List) & not .member(shop(ShopId,_),List)
<-
	.print("-> Shop: ", ShopId, " | Items: ", Items);
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

+working(JobId,Items2,StorageId)
	: shopsList(List) & baseListJob(Items)
<-
	for ( .member(item(ItemId,Qty),Items) )
	{
		?findShops(ItemId,List,[],Result);
		?bestShop(Result,Shop);
		if (buyList(ItemId,Qty2,Shop))
		{
			-buyList(ItemId,Qty2,Shop);
			+buyList(ItemId,Qty+Qty2,Shop);			
		} else {
			+buyList(ItemId,Qty,Shop);		
		}
	}
	.	
	
@decomp
+!decomp(Items)
	: true
<-
	+baseListJob([]);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!decomp_2(ItemId,Qty,BaseList);
	}
	for ( .member(consumed(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!decomp_2(ItemId,Qty,BaseList);
	}		
	.
	
@atomic	
+!decomp_2(ItemId,Qty,BaseList)
	: true 
<- 
	if (BaseList == []) {
			?baseListJob(List2);
			-+baseListJob([item(ItemId,Qty)|List2]);
	} else {
			for ( .range(I,1,Qty) ) {
				?assembleList(ListAssemble);
				-+assembleList([ItemId|ListAssemble]);				
				for ( .member(consumed(ItemId2,Qty2),BaseList) )
				{
					?product(ItemId2,Volume2,BaseList2);
					if (BaseList2 \== [])
					{
						?auxList(Aux);
						-+auxList([item(ItemId2,Qty2)|Aux]);						
					}
					!decomp_2(ItemId2,Qty2,BaseList2);
				}
			}
	}.
	
	