chargingList([]).
chargeTotal(3500).
shopsList([]).
itemList([]).

lowBattery :- charge(Battery) & Battery < 3000.

closestFacility(List,Facility) :- .nth(0,List,Facility).

bestShop(Shops,Shop) :- .nth(0,Shops,Shop).

findShops(ItemId,[],Aux,Result) :- Result = Aux.
findShops(ItemId,[shop(ShopId,ListItems)|List],Aux,Result) :- .member(item(ItemId,_,_,_),ListItems) & .concat([ShopId],Aux,ResultAux) & findShops(ItemId,List,ResultAux,Result).

+charge(Battery)
	: charging & chargeTotal(BatteryTotal) & BatteryTotal == Battery
<-
	.print("Stop charging, battery is full.");
	-charging;
	.

+pricedJob(JobId, StorageId, Begin, End, Reward, Items) 
	: not working(_,_,_)
<- 
	.print("New job: ",JobId," Items: ",Items);
	+working(JobId,Items,StorageId);
	.	

+working(JobId,Items,StorageId)
	: shopsList(List)
<-
	for ( .member(item(ItemId,Qty),Items) )
	{
		?findShops(ItemId,List,[],Result);
		.print("Shops with item ",ItemId,": ",Result);
		?bestShop(Result,Shop);
		+buyList(ItemId,Qty,Shop);
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

@buyTools
+!select_goal
	: inFacility(Facility) & shopsList(List) & .member(shop(Facility,_),List) & tools(Tools) & Tools \== []
<-
	.nth(0,Tools,Tool);
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

@chargeAction
+!select_goal 
	: lowBattery & inFacility(Facility) & chargingList(List) & .member(Facility,List) & not charging  
<- 
	.print("Began charging.");
	!charge;
	. 

@continueCharging
+!select_goal 
	: charging 
<- 
	.print("Keep charging."); 
	!continue;
	.

@buyAction
+!select_goal
	: buyList(Item,Qty,Shop) & inFacility(Shop) & not item(Item,_)
<-
	.print("Buying ",Qty,"x item ",Item);
	!buy(Item,Qty);
	+item(Item,Qty);
	-buyList(Item,Qty,Shop);
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

@skipAction
+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	