chargingList([]).
chargeTotal(3500).
shopsList([]).
itemList([]).

lowBattery :- charge(Battery) & Battery < 3000.

closestFacility(List,Facility) :- .nth(0,List,Facility).

processList(List,[ ],Aux,List2) :- true.
processList([item(ItemId,_)|Items],[shop(ShopId,ListItems)|List],Aux,List2) :- .member(item(ItemId,_,_,_),ListItems) & .concat([ShopId],List2,Result) & .print(Result) & processList([item(ItemId,_)],List,Aux,Result).
//processList([item(ItemId,_)|Items],[shop(ShopId,ListItems)|List],List2) :- processList([item(ItemId,_)],List,List2).

+charge(Battery)
	: charging & chargeTotal(BatteryTotal) & BatteryTotal == Battery
<-
	.print("Stop charging, battery is full.");
	-charging;
	.
/* 	
+item(Id,Qty)[artifact_id(_)]
	: true
<-
	+item(Id,Qty);
	.
*/	
+pricedJob(JobId, StorageId, Begin, End, Reward, Items) 
	: not working(_,_,_)
<- 
	+working(JobId,Items,StorageId);
	.
	
/*
+working(JobId,Items,StorageId)
	: shopsList(List) & Aux = []
<-
	?processList(Items,List,Aux,Result);
	.print("RESULT   ",Result);
	.	
*/	
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

+!select_goal 
	: lowBattery & inFacility(Facility) & chargingList(List) & .member(Facility,List) & not charging  
<- 
	.print("Began charging.");
	!charge;
	. 

+!select_goal 
	: charging 
<- 
	.print("Keep charging."); 
	!continue;
	.
	
+!select_goal 
	: not going(_) & lowBattery & chargingList(List) & closestFacility(List,Facility) 
<- 
	.print("Going to charging station ",Facility); 
	!goto(Facility);
	.

+!select_goal 
	: going(Facility) 
<-
	.print("Continuing to location ",Facility); 
	!continue;
	.
	
+!select_goal
	: inFacility(shop2) & not item(base1,_)
<-
	.print("Buying base1");
	!buy(base1,10);
	+item(base1,10);
	.

+!select_goal
	: inFacility(shop2) & not item(tool1,_)
<-
	.print("Buying tool1");
	!buy(tool1,1);
	+item(tool1,1);
	.			
	
+!select_goal
	: working(JobId,Items,StorageId)
<-
	.print("Going to shop2");
	!goto(shop2);
	.			

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	