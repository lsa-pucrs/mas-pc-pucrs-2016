chargingList([]).
chargeTotal(3500).
shopsList([]).
itemList([]).

lowBattery :- charge(Battery) & Battery < 3000.

closestFacility(List,Facility) :- .nth(0,List,Facility).

append([],L,L).
append([H|T],L2,[H|L3]) :-  append(T,L2,L3).

processList([],L,L2,LR).
processList([item(IID,_)|Items],[shop(SID,LI)|L],L2,LR) :- .member(item(IID,_,_,_),LI) & append(SID,L2,LR) & processList(Items,L,L2,LR).


+charge(Battery)
	: charging & chargeTotal(BatteryTotal) & BatteryTotal == Battery
<-
	.print("Stop charging, battery is full.");
	-charging;
	.
	
+pricedJob(JobId, StorageId, Begin, End, Reward, Items) 
	: not working(_,_,_)
<- 
	+working(JobId,Items,StorageId);
	.
	
+working(JobId,Items,StorageId)
	: shopsList(List) & processList(Items,List,[],Result)
<-
	.print(Result);
	
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
	: working(JobId,Items,StorageId)
<-
	.print("Going to shop ");
	.		

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	