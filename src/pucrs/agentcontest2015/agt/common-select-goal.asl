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
	: bid(JobId,Bid,Items,StorageId,MaxBid) & not postedBid(JobId) & going(Facility)
<-
	!bid_for_job(JobId,Bid);
	.print("Had to stop to post bid ",Bid," for job: ",JobId," which had max bid of ",MaxBid);
	+auctionJob(JobId,Items,StorageId);
	+postedBid(JobId);
	+remember(Facility);
	.

@postBidAlt
+!select_goal
	: bid(JobId,Bid,Items,StorageId,MaxBid) & not postedBid(JobId)
<-
	!bid_for_job(JobId,Bid);
	.print("Posted bid ",Bid," for job: ",JobId," which had max bid of ",MaxBid);
	+auctionJob(JobId,Items,StorageId);
	+postedBid(JobId);
	.
	
@assembleTool
+!select_goal 
	: assembleToolsList(ListAssemble) & ListAssemble \== [] & .nth(0,ListAssemble,ItemId) & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) & product(ItemId,Volume,Bases) & verifyItems(Bases) 
<- 
	.print("Assembling tool ", ItemId, " in workshop ", Facility);	
	!assemble(ItemId);
	-assembleToolsList(ListAssemble);
	.delete(0,ListAssemble,ListAssembleNew);
	+assembleToolsList(ListAssembleNew);
	?item(ItemId,Qty);
	-item(ItemId,Qty);
	+item(ItemId,Qty+1);
	for (.member(consumed(ItemIdBase,QtyBase),Bases))  {
		?item(ItemIdBase,Qty2);
		-item(ItemIdBase,Qty2);
		+item(ItemIdBase,Qty2-QtyBase);
	};
	.
	
@gotoWorkshopToAssembleTool
+!select_goal 
	: assembleToolsList(ListAssemble) & ListAssemble \== [] & workshopList(WorkshopList) & closestFacility(WorkshopList,Facility) & not going(_) & not buyList(_,_,_) & compositeMaterials(CompositeList) & .intersection(ListAssemble,CompositeList,Inter) & verifyTools(Inter,[],ToolsMissing)
<-
	if (ToolsMissing \== [])
	{
		?serverName(Name);
	    for (.member(assemble(ItemId,Tool),ToolsMissing))
	    {
	  		?count(ItemId,ListAssemble,0,Qty);
	  		.print("I need help assembling tool ",Qty,"x: ",ItemId, " with ",Tool," in ",Facility);
	  		.broadcast(tell,helpAssemble(ItemId,Qty,Tool,Facility,Name));
	  		+waitingForAssistAssemble(ItemId,Qty,Tool,Facility,Name); 		
	    }
	    
	}
	.print("I'm going to workshop ", Facility);
	!goto(Facility);
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
	: working(JobId,Items,StorageId) & inFacility(StorageId) & verifyItems(Items) & loadExpected(LoadE)
<- 
	!deliver_job(JobId);
	-working(JobId,Items,StorageId);
	+jobDone(JobId);
	.print("Job ", JobId, " has been delivered.");
	+countAux(0);
	for ( .member(item(ItemId,Qty),Items))  {
		?product(ItemId,Volume,BaseList);
		-item(ItemId,Qty);
		+item(ItemId,0);
		?countAux(X);
		-+countAux(X + Qty * Volume);
	}
	?countAux(X);
	-countAux(X);
	-+loadExpected(LoadE-X);
	.
	
@storeItem
+!select_goal 
	: inFacility(Facility) & storageList(List) & .member(Facility,List) & storeList(Items) & Items \== [] & .nth(0,Items,item(ItemId,Qty))
<- 
	!store(ItemId,Qty);
	?item(IdemId,Qty2);
	-item(ItemId,Qty2);
	+item(ItemId,Qty2-Qty);
	-storeList(Items);
	.delete(0,Items,ItemsNew);
	+storeList(ItemsNew);	
	.
	
@retrieveItem
+!select_goal 	
	: inFacility(Facility) & storageList(List) & .member(Facility,List) & retrieveList(Items) & Items \== [] & .nth(0,Items,item(ItemId,Qty))
<- 
	!retrieve(ItemId,Qty);
	?item(IdemId,Qty2);
	-item(ItemId,Qty2);
	+item(ItemId,Qty2+Qty);
	-retrieveList(Items);
	.delete(0,Items,ItemsNew);
	+retrieveList(ItemsNew);		
	.	
	
@retrieveDeliveredPartial
+!select_goal 	
	: partial(JobId,Items,StorageId) & inFacility(StorageId) & Items \== [] & .nth(0,Items,item(ItemId,Qty))
<- 
	!retrieve_delivered(ItemId,Qty);
	?item(IdemId,Qty2);
	-item(ItemId,Qty2);
	+item(ItemId,Qty2+Qty);
	-partial(JobId,Items,StorageId);
	.delete(0,Items,ItemsNew);
	+partial(JobId,ItemsNew,StorageId);
	.	
	
@retrieveDeliveredJob
+!select_goal 	
	: delivered(JobId,Items,StorageId) & inFacility(StorageId) & Items \== [] & .nth(0,Items,item(ItemId,Qty))
<- 
	!retrieve_delivered(ItemId,Qty);
	?item(IdemId,Qty2);
	-item(ItemId,Qty2);
	+item(ItemId,Qty2+Qty);
	-delivered(JobId,Items,StorageId);
	.delete(0,Items,ItemsNew);
	+delivered(JobId,ItemsNew,StorageId);
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
	: assembleList(ListAssemble) & ListAssemble \== [] & .nth(0,ListAssemble,ItemId) & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) & product(ItemId,Volume,Bases) & iAmHere(ItemId,_,Tool,FacilityHelp,Agent)
<- 
	.print("Assembling, with assist, item ", ItemId, " in workshop ", Facility);	
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
	: waitingForAssistAssemble(ItemId,Qty,Tool,Facility,Name)
<-
	.print("I am waiting for help to assemble some items.");
	.broadcast(tell,helpAssemble(ItemId,Qty,Tool,Facility,Name));	
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
	  		+waitingForAssistAssemble(ItemId,Qty,Tool,Facility,Name);  		
	    }
	    .nth(0,ToolsMissing,assemble(ItemId2,Tool2));
	    ?count(ItemId2,ListAssemble,0,Qty2);
  		.print("I need help assembling ",Qty2,"x: ",ItemId2, " with ",Tool2," in ",Facility);
  		.broadcast(tell,helpAssemble(ItemId2,Qty2,Tool2,Facility,Name));	
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
	for (iAmHere(ItemId,Qty,Tool,FacilityHelp,Agent)[source(X)])
	{
		-iAmHere(ItemId,Qty,Tool,FacilityHelp,Agent)[source(X)];
		.send(X,untell,helpAssemble(ItemId,Qty,Tool,FacilityHelp,Agent));
	}
	// clearing bases used to assemble
	-baseListJob(_);
	-auxList(_);
	+auxList([]);
	!goto(StorageId);
	.

/*
+lastActionResult(give, successful)
	: true
<-
	-hasToGive(ItemId,Qtd);
	-item(ItemId,Qtd);
	.
*/

// Give item to other agent
// TODO: message
+!select_goal
    : false & inFacility(dump1) & hasToGive(ItemId, Qty)
<-
    .print("I am giving item ", ItemId, "(", Qty, ") to agent a4");
    !give(a4, ItemId, Qty);
    ?item(ItemId, NewQty);
    if(NewQty < Qty){
    	-hasToGive(ItemId, Qty)
    }
	.

// Receive item from other agent
// TODO: message
+!select_goal
    : false & inFacility(dump1) & hasToReceive(ItemId, Qty)
<-
    .print("I am retrieving item ", ItemId, "(", Qty, ") from agent a1");
    !receive;
    ?item(ItemId, NewQty);
    if(NewQty > Qty){
    	-hasToReceive(ItemId, Qty)
    }
	.

// Giver goto meeting place
+!select_goal
    : false & not going(_) & roled("Car", _, _, _, _) & item(ItemId, Qty) & Qty > 0
<-
    //.print(">>>>>>>>> I am going to ", FacilityId, " to give/retrieve item(", ItemId, Qty, ") to agent ", AgentId);
    .print("I am going to ", dump1, " to give/retrieve item(", ItemId, Qty, ") to agent ?");
    //!goto(FacilityId);
    +hasToGive(ItemId, Qty);
    !goto(dump1);
	.

// Receiver goto meeting place
+!select_goal
    : false & not going(_) & roled("Truck", _, _, _, _) & item(ItemId, Qty) & Qty > 0
<-
    //.print(">>>>>>>>> I am going to ", FacilityId, " to give/retrieve item(", ItemId, Qty, ") to agent ", AgentId);
    .print("I am going to ", dump1, " to give/retrieve item(", ItemId, Qty, ") to agent ?");
    //!goto(FacilityId);
    +hasToReceive(ItemId, Qty);
    !goto(dump1);
	.

// Dump if in facility, not working and have any item different from a tool
+!select_goal
	: item(ItemId,Qty) & Qty > 0 & not isTool(ItemId) & inFacility(DumpId) & dumpList(DumpList) & .member(DumpId,DumpList)
<- 
	.print("Dumping ", ItemId, "(", Qty, ")");
	!dump(ItemId, Qty);
	-item(ItemId, Qty);
	.

// Goto dump facility if not working and have any item different from a tool
+!select_goal
	: free & item(ItemId,Qty) & Qty > 0 & not isTool(ItemId) & dumpList(DumpList) & not working(_,_,_)
<-
	?closestFacility(DumpList, DumpId);
	.print("I am going to ", DumpId);
	!goto(DumpId);
	.

// Default action is to skip
@skipAction
+!select_goal
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.