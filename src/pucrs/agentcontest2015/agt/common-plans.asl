+step(Step) 
	: true
<-
 	-+lastStep(Step);
	!select_goal;
	.
	
+inFacility(Facility)
	: Facility \== none
<-
	-going(Facility);
	.
	
+item(ItemId,Qty)
	: buyList(ItemId,Qty,Shop)
<-
	-buyList(ItemId,Qty,Shop);
	.

+item(ItemId,1)
	: assembleList(ItemId,Workshop)
<-
	-assembleList(ItemId,Workshop);
	.

+lastActionResult(Result)
	: Result == failed_random & lastActionReal(Action) & step(Step) & going(Facility)
<-
	.print("Failed to execute action ",Action," on step ",Step," due to the 1% random error.");
	+remember(Facility);
	.

+lastActionResult(Result)
	: Result == failed_random & lastActionReal(Action) & step(Step)
<-
	.print("Failed to execute action ",Action," on step ",Step," due to the 1% random error.");
	.
	
@shopList[atomic]
+shop(ShopId, Lat, Lng, Items)
	: shopList(List) & not .member(shop(ShopId,_),List)
<-
	-+shopList([shop(ShopId,Items)|List]);
	.
	
@storageList[atomic]
+storage(StorageId, Lat, Lng, Price, TotCap, UsedCap, Items)
	: storageList(List) & not .member(StorageId,List)
<-
	-+storageList([StorageId|List]);
	.	
	
@chargingList[atomic]
+chargingStation(ChargingId,Lat,Lng,Rate,Price,Slots) 
	:  chargingList(List) & not .member(ChargingId,List) //& chargingPrice(Price2,Rate2)
<- 
//	if (Price > Price2)
//	{
//		-+chargingPrice(Price,Rate);
//	}	
	-+chargingList([ChargingId|List]);
	.
	
@workshopList[atomic]
+workshop(WorkshopId,Lat,Lng,Price) 
	:  workshopList(List) & not .member(WorkshopId,List)  //& workshopPrice(Price2)
<- 
//	if (Price > Price2)
//	{
//		-+workshopPrice(Price);
//	}
	-+workshopList([WorkshopId|List]);
	.
	
@dumpList[atomic]
+dump(DumpId,Lat,Lng,Price) 
	:  dumpList(List) & not .member(DumpId,List) 
<- 
	-+dumpList([DumpId|List]);
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
	
@decomp2
+!decomp_2(ItemId,Qty,BaseList)
	: true 
<- 
	if (BaseList == []) {
			?baseListJob(List2);
			-+baseListJob([item(ItemId,Qty)|List2]);
	} else {
//			for ( .range(I,1,Qty) ) {
//				?assembleList(ListAssemble);
//				-+assembleList([ItemId|ListAssemble]);				
			for ( .member(consumed(ItemId2,Qty2),BaseList) )
			{
				?product(ItemId2,Volume2,BaseList2);
//				if (BaseList2 \== [])
//				{
//					?auxList(Aux);
//					-+auxList([item(ItemId2,Qty2)|Aux]);						
//				}
				!decomp_2(ItemId2,Qty2,BaseList2);
			}
//			}
	}
	.
	
/* 
+simEnd
	: roled(Role, Speed, LoadCap, BatteryCap, Tools) & current_wsp(WSid,WSname,WScode) & jcm__art("puc",Art1,ArtId1) & jcm__art("city",Art2,ArtId2) & jcm__ws("puc",WSid1) & jcm__ws("city",WSid2) & serverName(ServerName)
<-
	!end_round;
	!new_round(Role, Speed, LoadCap, BatteryCap, Tools);
	+roled(Role, Speed, LoadCap, BatteryCap, Tools);
	+serverName(ServerName);	
	+current_wsp(WSid,WSname,WScode);	
	+jcm__ws("puc",WSid1);
	+jcm__ws("city",WSid2);
	+jcm__art("puc",Art1,ArtId1);
	+jcm__art("city",Art2,ArtId2);	
	.
	
@goHorse[atomic]	
+lastStep(Step)
	: steps(TotalSteps) & Step >= TotalSteps - 20 & not goHorse
<-
	+goHorse;
	.print("|||GOHORSE|||");
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

@helpAssemble[atomic]
+helpAssemble(ItemId,Qty,Tool,Facility,Agent)[source(X)]
	: item(Tool,1) & free & not working(_,_,_) & not helping
<-
	+helping;
	+warnAgent;
	.send(X,tell,iAmGoing(ItemId,Qty,Tool,Facility,Agent));
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
	for (helpAssemble(_,_,_,_,_)[source(X)])
	{
		-helpAssemble(_,_,_,_,_)[source(X)];
	}
	+abort;
	-helping;
	.	
	
-helpAssemble(ItemId,Qty,Tool,Facility,Agent)[source(X)]
	: helping
<-
	-helping;
	.		
	
+iAmHere(ItemId,Qty,Tool,FacilityHelp,Agent)[source(X)]
	: true
<-	
	-waitingForAssistAssemble(ItemId,Qty,Tool,FacilityHelp,Agent);
	.
	
+shop(ShopId, Lat, Lng, Items)
	: items_has_price(Items) & roled(Role, _, _, _, _) & Role \== "Truck" // this could be optimized
<-  
	for(.member(item(NItem,Price,Qty,Load),Items))
	{
		?item_qty(ShopId, NItem, Qty2);
		if (Qty2 \== Qty)
		{
			-item_qty(ShopId, NItem, Qty2);
			+item_qty(ShopId, NItem, Qty);
		}
	}
	.
	
+shop(ShopId, Lat, Lng, Items)
	: items_has_price(Items) & roled(Role, _, _, _, _) & Role == "Truck" // this could be optimized
<-  
	for(.member(item(NItem,Price,Qty,Load),Items))
	{
		?item_qty(ShopId, NItem, Qty2);
		if (Qty2 \== Qty)
		{
			-item_qty(ShopId, NItem, Qty2);
			+item_qty(ShopId, NItem, Qty);
		}
		if(not(item_price(NItem,Price2)) | (item_price(NItem,Price2) & Price > Price2))
		{
			-item_price(NItem,Price2);
			+item_price(NItem,Price);
		}		 
	}
	!!calculate_materials_prices;
	.	

+working(JobId,Items2,StorageId)
	: shopsList(List) & baseListJob(Items)
<-
	for ( .member(item(ItemId,Qty),Items) )
	{
		?find_shops(ItemId,List,Result);
		?best_shop(Result,Shop);
		if (buyList(ItemId,Qty2,Shop))
		{
			-buyList(ItemId,Qty2,Shop);
			+buyList(ItemId,Qty+Qty2,Shop);			
		} else {
			+buyList(ItemId,Qty,Shop);		
		}
	}
	.	
*/
	
	