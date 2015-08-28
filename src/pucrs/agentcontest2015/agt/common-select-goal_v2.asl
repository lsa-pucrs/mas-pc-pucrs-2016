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
	
//################################### NEW CODE ########################################

@assembleTools
+!select_goal
	: tools(Tools) & Tools \== [] & not going(_) & .nth(0,Tools,Tool) & product(Tool, Vol, BaseList) & BaseList \== [] & not(working(Tool))
<-
	.print("Going to assemble tool:", Tool);
	+baseListTool([]);	
	+assembleListTool([]);
	for ( .member(consumed(ItemId,Qty),BaseList))
	{
		?product(ItemId,Volume2,BaseList2);
		!decomp_3(ItemId,Qty,BaseList2);
	}
	+working(Tool);
	.
	

+!decomp_3(ItemId,Qty,BaseList)
	: true 
<- 
	if (BaseList == []) {
			?baseListTool(List2);
			-+baseListTool([item(ItemId,Qty)|List2]);
	} else {
			for ( .range(I,1,Qty) ) {
				?assembleListTool(ListAssemble);
				-+assembleListTool([ItemId|ListAssemble]);				
				for ( .member(consumed(ItemId2,Qty2),BaseList) )
				{
					?product(ItemId2,Volume2,BaseList2);
					!decomp_3(ItemId2,Qty2,BaseList2);
				}
			}
	}.
	
+working(Tool)
	: shopsList(List) & baseListTool(Items)
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
	
@buyActionTool
+!select_goal
	: buyList(Item,Qty,Shop) & inFacility(Shop) & item(Item,Qty2)
<-
	.print("Buying ",Qty,"x item ",Item);
	!buy(Item,Qty);
	-item(Item,Qty2);
	+item(Item,Qty+Qty2);
	-buyList(Item,Qty,Shop);
	.
//##############################################################################################

@buyTools
+!select_goal
	: inFacility(Facility) & tools(Tools) & Tools \== [] & .nth(0,Tools,Tool) &  shopsList(List) & findShops(Tool,List,[],Result) & .member(Facility,Result) & not item(Tool,1)
	&  product(Tool, Vol, BaseList) & BaseList == []
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
	//.print("In facility ", StorageId, " to deliver job ", JobId);
	!deliver_job(JobId);
	-working(JobId,Items,StorageId);
	+jobDone(JobId);
	.print("Job ", JobId, " has been delivered.");
	for ( .member(item(ItemId,Qty),Items))  {
		-item(ItemId,Qty);
		+item(ItemId,0);
	}
	.
	
	//##################################### NEW CODE ##################################################

@assembleItemsTool
+!select_goal 
	: working(Tool) & assembleListTool(ListAssemble) & ListAssemble \== [] & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) 
<- 
	.nth(0,ListAssemble,ItemId);
	.print("Assembling item ", ItemId, " in workshop ", Facility);	
	!assemble(ItemId);
	-assembleListTool(ListAssemble);
	.delete(0,ListAssemble,ListAssembleNew);
	+assembleListTool(ListAssembleNew);
	?item(ItemId,Qty);
	-item(ItemId,Qty);
	+item(ItemId,Qty+1);
	?product(ItemId,Volume,Bases);
	for (.member(consumed(ItemIdBase,QtyBase),Bases))  {
		?item(ItemIdBase,Qty2);
		-item(ItemIdBase,Qty2);
		+item(ItemIdBase,Qty2-QtyBase);
	};
	.
	
@assembleTool
+!select_goal 
	: working(Tool) & assembleListTool(ListAssemble) & ListAssemble == [] & inFacility(Facility) & workshopList(ListWorkshop) & .member(Facility,ListWorkshop) 
<- 
	.print("Assembling tool ", Tool, " in workshop ", Facility);	
	!assemble(Tool);
	?item(Tool,Qty);
	-item(Tool,Qty);
	+item(Tool,Qty+1);
	?product(Tool,Volume,Bases);
	for (.member(consumed(ItemIdBase,QtyBase),Bases))  {
		?item(ItemIdBase,Qty2);
		-item(ItemIdBase,Qty2);
		+item(ItemIdBase,Qty2-QtyBase);
	};
	?tools(Tools);
	-tools(Tools);
	.delete(Tool,Tools,ToolsNew);
	+tools(ToolsNew);
	-working(Tool);
	.
//###################################################################################################
	
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
	-item(ItemId,Qty);
	+item(ItemId,Qty+1);
	?product(ItemId,Volume,Bases);
	for (.member(consumed(ItemIdBase,QtyBase),Bases))  {
		?item(ItemIdBase,Qty2);
		-item(ItemIdBase,Qty2);
		+item(ItemIdBase,Qty2-QtyBase);
	};
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

//################################## NEW CODE ###############################################	

@gotoShopItensTool
+!select_goal
	: working(Tool) & buyList(Item,Qty,Shop)
<-
	.print("Going to ",Shop);
	!goto(Shop);
	.	
	
@gotoWorkshopTool
+!select_goal
	: working(Tool) & assembleListTool(ListAssemble) & ListAssemble \== [] & workshopList(WorkshopList) & closestFacility(WorkshopList,Facility) & not going(_) & not buyList(_,_,_)
<-
	.print("I'm going to workshop ", Facility);
	!goto(Facility);
	.
//#################################################################################	
	
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
	: working(JobId,Items,StorageId) & verifyItems(Items) & not going(_) & not buyList(_,_,_) & baseListJob(Bases) & auxList(Aux)
<-
	.print("I have all items for job ",JobId,", now I'm going to deliver the job at ", StorageId);
	// clearing bases used to assemble
	-baseListJob(_);
	-auxList(_);
	+auxList([]);
	!goto(StorageId);
	.		

@skipAction
+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	