@abort
+!select_goal
	: going(Facility) & abort
<-
	.print("Aborting goto action to help, agent does not need my help anymore.");
	-abort;
	-going(Facility);
	!abort;
	.

@remember
+!select_goal
	: remember(Facility)
<-
	.print("Had to stop my continue, initiating go to again to ",Facility); 
	-remember(Facility);
	!goto(Facility);
	.

@postBid
+!select_goal
	: bid(JobId,Bid,Items,StorageId) & not postedBid(JobId) & going(Facility)
<-
	!bid_for_job(JobId,Bid);
	.print("Posted bid ",Bid," for job: ",JobId);
	+auctionJob(JobId,Items,StorageId);
	+postedBid(JobId);
	+remember(Facility);
	.

@postBidAlt
+!select_goal
	: bid(JobId,Bid,Items,StorageId) & not postedBid(JobId)
<-
	!bid_for_job(JobId,Bid);
	.print("Posted bid ",Bid," for job: ",JobId);
	+auctionJob(JobId,Items,StorageId);
	+postedBid(JobId);
	.

@buyTools
+!select_goal
	: inFacility(Facility) & tools(Tools) & Tools \== [] & .nth(0,Tools,Tool) &  shopsList(List) & findShops(Tool,List,[],Result) & .member(Facility,Result) & not item(Tool,1)
<-
	.print("Buying tool: ",Tool);
	!buy(Tool,1);
	-item(Tool,0);
	+item(Tool,1);
	-tools(Tools);
	.delete(0,Tools,ToolsNew);
	+tools(ToolsNew);
	.
		
@goBuyTools
+!select_goal
	: tools(Tools) & Tools \== [] & shopsList(List) & not going(_) & .nth(0,Tools,Tool) & product(Tool, Vol, BaseList) & BaseList == []
<-
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
	-item(Item,Qty2);
	+item(Item,Qty+Qty2);
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
	: working(JobId,Items,StorageId) & inFacility(StorageId) & verifyItems(Items)
<- 
	!deliver_job(JobId);
	-working(JobId,Items,StorageId);
	+jobDone(JobId);
	.print("Job ", JobId, " has been delivered.");
	for ( .member(item(ItemId,Qty),Items))  {
		-item(ItemId,Qty);
		+item(ItemId,0);
	}
	.

@assistAssemble
+!select_goal
	: helpAssemble(ItemId,Qty,Tool,Facility,Agent) & inFacility(Facility)
<-
	.print("I am assisting agent ",Agent," in order to make ",Qty,"x of item ",ItemId);
	!assist_assemble(Agent);
	.

@assembleItemWithAssist
+!select_goal 
	: assembleList(ListAssemble) & ListAssemble \== [] & .nth(0,ListAssemble,ItemId) & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) & product(ItemId,Volume,Bases) & iAmHere
<- 
	.print("Assembling item ", ItemId, " in workshop ", Facility);	
	!assemble(ItemId);
	-assembleList(ListAssemble);
	.delete(0,ListAssemble,ListAssembleNew);
	+assembleList(ListAssembleNew);
	?item(ItemId,Qty);
	-item(ItemId,Qty);
	+item(ItemId,Qty+1);
	for (.member(consumed(ItemIdBase,QtyBase),Bases))  {
		?item(ItemIdBase,Qty2);
		-item(ItemIdBase,Qty2);
		+item(ItemIdBase,Qty2-QtyBase);
	};
	.
	
@assembleItem
+!select_goal 
	: assembleList(ListAssemble) & ListAssemble \== [] & .nth(0,ListAssemble,ItemId) & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) & product(ItemId,Volume,Bases) & verifyItems(Bases) 
<- 
	.print("Assembling item ", ItemId, " in workshop ", Facility);	
	!assemble(ItemId);
	-assembleList(ListAssemble);
	.delete(0,ListAssemble,ListAssembleNew);
	+assembleList(ListAssembleNew);
	?item(ItemId,Qty);
	-item(ItemId,Qty);
	+item(ItemId,Qty+1);
	for (.member(consumed(ItemIdBase,QtyBase),Bases))  {
		?item(ItemIdBase,Qty2);
		-item(ItemIdBase,Qty2);
		+item(ItemIdBase,Qty2-QtyBase);
	};
	.

@continueCharging
+!select_goal 
	: charging //& charge(Battery) & chargeTotal(BatteryCap) & Battery < BatteryCap
<- 
	.print("Keep charging."); 
	!continue;
	.
	
@gotoCharging	
+!select_goal 
	: lowBattery & chargingList(List) & closestFacility(List,Facility) 
<- 
	.print("Going to charging station ",Facility);
	if (going(Facility))
	{
		+remember(Facility);
	} 
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
	: buyList(Item,Qty,Shop)
<-
	.print("Going to ",Shop);
	!goto(Shop);
	.		
	
@waitingForAssistAssemble
+!select_goal
	: waitingForAssistAssemble
<-
	.print("I am waiting for help to assemble some items.");
	!skip;	
	.
	
@gotoWorkshopToAssist
+!select_goal
	: helpAssemble(ItemId,Qty,Tool,Facility,Agent)
<-
	.print("I'm going to workshop ", Facility, " to assist agent ",Agent," in order to make ",Qty,"x of item ",ItemId);
	!goto(Facility);	
	.	
	
@gotoWorkshop
+!select_goal
	: assembleList(ListAssemble) & ListAssemble \== [] & workshopList(WorkshopList) & closestFacility(WorkshopList,Facility) & not going(_) & not buyList(_,_,_) & compositeMaterials(CompositeList) & .intersection(ListAssemble,CompositeList,Inter) & verifyTools(Inter,[],ToolsMissing)
<-
	if (ToolsMissing \== [])
	{
		?serverName(Name);
	    for (.member(assemble(ItemId,Tool),ToolsMissing))
	    {
	  		?count(ItemId,ListAssemble,0,Qty);
	  		.print("I need help assembling ",Qty,"x: ",ItemId, " with ",Tool," in ",Facility);
	  		.broadcast(tell,helpAssemble(ItemId,Qty,Tool,Facility,Name));	  		
	    }
	    +waitingForAssistAssemble;
	}
	.print("I'm going to workshop ", Facility);
	!goto(Facility);
	.

@gotoStorageToDeliverJob
+!select_goal
	: working(JobId,Items,StorageId) & verifyItems(Items) & not going(_) & not buyList(_,_,_) & baseListJob(Bases) & auxList(Aux)
<-
	.print("I have all items for job ",JobId,", now I'm going to deliver the job at ", StorageId);
	// let agents know you do not need help anymore
	for (iAmHere[source(X)])
	{
		-iAmHere[source(X)];
		.send(X,untell,helpAssemble(_,_,_,_,_));
	}
	// clearing bases used to assemble
	-baseListJob(_);
	-auxList(_);
	+auxList([]);
	!goto(StorageId);
	.		

+!select_goal
	: not working(_,_,_) & item(ItemId,Qty) & Qty > 0 & not isTool(ItemId) & inFacility(DumpId) & dumpList(DumpList) & .member(DumpId,DumpList)
<- 
	.print("Dumping ", ItemId, "(", Qty, ")");
	!dump(ItemId, Qty);
	-item(ItemId,Qty);
.

+!select_goal
	: not working(_,_,_) & item(ItemId,Qty) & Qty > 0 & not isTool(ItemId) & dumpList(DumpList)
<-
	?bestFacility(DumpList, DumpId);
	.print("I am going to ", DumpId);
	!goto(DumpId);
	.

@skipAction
+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	