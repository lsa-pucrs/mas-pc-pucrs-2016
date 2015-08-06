chargingList([]).
chargeTotal(3500).
shopsList([]).
workshopList([]).
assembleList([]).

lowBattery :- charge(Battery) & Battery < 3000.

closestFacility(List,Facility) :- .nth(0,List,Facility).

bestShop(Shops,Shop) :- .nth(0,Shops,Shop).

verifyItems([]).
verifyItems([item(ItemId,Qty)|List]) :- item(ItemId,Qty) & verifyItems(List).

findShops(ItemId,[],Aux,Result) :- Result = Aux.
findShops(ItemId,[shop(ShopId,ListItems)|List],Aux,Result) :- .member(item(ItemId,_,_,_),ListItems) & .concat([ShopId],Aux,ResultAux) & findShops(ItemId,List,ResultAux,Result).

@product[atomic]
+product(ProductId, Volume, BaseList)[artifact_id(_)]
	: not product(ProductId, Volume, BaseList)
<-
	+product(ProductId, Volume, BaseList);
	+item(ProductId,0);
	.

+charge(Battery)
	: charging & chargeTotal(BatteryTotal) & BatteryTotal == Battery
<-
	.print("Stop charging, battery is full.");
	-charging;
	.

+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: not working(_,_,_) & not jobDone(JobId)
<- 
	.print("New job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	+baseListJob([]);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		if (BaseList == []) {
			?baseListJob(List2);
			-+baseListJob([item(ItemId,Qty)|List2]);
			.print("Adding item ",ItemId," to base list job.");
		} else {
				for ( .range(I,1,Qty) ) {
					?assembleList(ListAssemble);
					-+assembleList([ItemId|ListAssemble]);				
					for ( .member(consumed(ItemId2,Qty2),BaseList) )
					{
						?product(ItemdId2,Volume2,BaseList2);
						if (BaseList2 == [])
						{
							?baseListJob(List2);
							-+baseListJob([item(ItemId2,Qty2)|List2]);
							.print("Adding base ",ItemId2," for material item ",ItemId," to base list job.");
						}
					}
				}
		}
	}	
	+working(JobId,Items,StorageId);
	.	

+working(JobId,Items2,StorageId)
	: shopsList(List) & baseListJob(Items)
<-
	-baseListJob(_);	
	for ( .member(item(ItemId,Qty),Items) )
	{
		?findShops(ItemId,List,[],Result);
		.print("Shops with item ",ItemId,": ",Result);
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
	
+inFacility(Facility)[artifact_id(_)]
	: going(GoingFacility) & Facility == GoingFacility 
<- 
	if (going(GoingFacility) & Facility == GoingFacility) {
		-going(GoingFacility);
	};
	-+inFacility(Facility);
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

@buyTools
+!select_goal
	: inFacility(Facility) & tools(Tools) & Tools \== [] & .nth(0,Tools,Tool) &  shopsList(List) & findShops(Tool,List,[],Result) & .member(Facility,Result) & not item(Tool,1)
<-
	.print("Buying tool: ",Tool);
	!buy(Tool,1);
	+item(Tool,1);
	-tools(Tools);
	.delete(0,Tools,ToolsNew);
	+tools(ToolsNew);
	.
		
@goBuyTools
+!select_goal
	: tools(Tools) & Tools \== [] & shopsList(List) & not going(_)
<-
	.nth(0,Tools,Tool);
	?findShops(Tool,List,[],Result);
	?bestShop(Result,Shop);
	.print("Going to shop: ",Shop," to buy tool: ",Tool);
	!goto(Shop);
	.
	
@buyAction
+!select_goal
	: buyList(Item,Qty,Shop) & inFacility(Shop) & item(Item,Qty2)
<-
	.print("Buying ",Qty,"x item ",Item);
	!buy(Item,Qty);
	-item(Item,Qty);
	+item(Item,Qty2);
	-buyList(Item,Qty,Shop);
	.

@chargeAction
+!select_goal 
	: lowBattery & inFacility(Facility) & chargingList(List) & .member(Facility,List) & not charging  
<- 
	.print("Began charging.");
	!charge;
	. 

@deliverJob
+!select_goal 
	: working(JobId,Items,StorageId) & inFacility(StorageId) 
<- 
	.print("In facility ", StorageId, " to deliver job ", JobId);
	!deliver_job(JobId);
	-working(JobId,Items,StorageId);
	+jobDone(JobId);
	.print("Job ", JobId, " has been delivered.");
	for ( .member(item(ItemId,Qty),Items))  {
		-item(ItemId,Qty);
	}
	.
	
@assembleItem
+!select_goal 
	: working(JobId,Items,StorageId) & assembleList(ListAssemble) & ListAssemble \== [] & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) 
<- 
	.nth(0,ListAssemble,ItemId);
	.print("Assembling item ", ItemId, " in workshop ", Facility);	
	!assemble(ItemId);
	-assembleList(ListAssemble);
	.delete(0,ListAssemble,ListAssembleNew);
	+assembleList(ListAssembleNew);
	?item(ItemId,Qty);
	-+item(ItemId,Qty+1);
	.

@continueCharging
+!select_goal 
	: charging 
<- 
	.print("Keep charging."); 
	!continue;
	.
	
@gotoCharging	
+!select_goal 
	: not going(_) & lowBattery & chargingList(List) & closestFacility(List,Facility) 
<- 
	.print("Going to charging station ",Facility); 
	!goto(Facility);
	.	
	
@continueGoto
+!select_goal 
	: going(Facility) 
<-
	.print("Continuing to location ",Facility); 
	!continue;
	.		
	
@gotoShop
+!select_goal
	: working(JobId,Items,StorageId) & buyList(Item,Qty,Shop)
<-
	.print("Going to ",Shop);
	!goto(Shop);
	.		
	
@gotoWorkshop
+!select_goal
	: working(JobId,Items,StorageId) & assembleList(ListAssemble) & ListAssemble \== [] & workshopList(WorkshopList) & closestFacility(WorkshopList,Facility) & not going(_) & not buyList(_,_,_)
<-
	.print("I'm going to workshop ", Facility);
	!goto(Facility);
	.

@gotoStorageToDeliverJob
+!select_goal
	: working(JobId,Items,StorageId) & verifyItems(Items) & not going(_) & not buyList(_,_,_)
<-
	.print("I have all items for job ",JobId,", now I'm going to deliver the job at ", StorageId);
	!goto(StorageId);
	.		

@skipAction
+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	