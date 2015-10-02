@task[atomic]
+task(Task,CNPBoard) 
	: roled(Role, Speed, LoadCap, BatteryCap, Tools)
<- 
	.print("Found a task: ",Task);
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
	!make_bid(Task,BoardId,CNPBoard);
	.

@winner[atomic]
+winner(BidId,Task,Items,JobId,StorageId) 
	: my_bid(BidId,Task)
<- 
	.print("Awarded!.");
	+noBids;
	!decomp([Items]);
	+working(JobId,[Items],StorageId);
	.
@winner2[atomic]	
+winner(BidId,Task,item(ItemId,Qty),JobId,StorageId) 
	: my_bid(X,Y) & not my_bid(BidId,Task) & product(ItemId, Volume, BaseList) & loadExpected(LoadE)
<- 
	.print("Not awarded.");
	-+loadExpected(LoadE - Volume * Qty);
	.
	
+!make_bid(Task,BoardId,CNPBoard)
	: not noBids
<- 
	!create_bid(Task,Bid);
	bid(Bid,BidId)[artifact_id(BoardId)];
	+my_bid(BidId,CNPBoard);
	.print("Bid submitted: ",Bid," - id: ",BidId, " for task: ",CNPBoard);
	.
-!make_bid(Task,BoardId,CNPBoard)
	: noBids
<- 
	.print("No more bids for me.");
	.
-!make_bid(Task,BoardId,CNPBoard)
<- 
	.print("Too late for submitting the bid.");
	.drop_all_intentions;
	.
	
@create_bid[atomic]	
+!create_bid(item(ItemId,Qty),Bid)
	: product(ItemId, Volume, BaseList) & loadExpected(LoadE) & load(Load) & loadTotal(LoadCap) & workshopList(WList) & .nth(0,WList,WorkshopId) & shopsList(SList) & .nth(0,SList,shop(ShopId,_)) & storageList(StList) & .nth(0,StList,StorageId) & roled(_, Speed, _, _, _)
<- 
	?closestFacility([WorkshopId], FacilityA, RouteLenWorkshop);
	?closestFacility([ShopId], FacilityB, RouteLenShop);
	?closestFacility([StorageId], FacilityC, RouteLenStorage);	
	?calculateBasesLoad(BaseList,Qty,0,LoadB);
	
	?verifyTools([ItemId],[],ToolsMissing);
	if (ToolsMissing \== [])
	{
		.length(ToolsMissing,L);
		ToolFactor = 2 ** L;
	}
	else {
		ToolFactor = 1;
	}
	
	if ( (LoadB > Volume * Qty) & (LoadCap - Load >= LoadB + LoadE) )
	{
		-+loadExpected(LoadB + LoadE);
		Bid = math.round((RouteLenWorkshop / Speed) + (RouteLenShop / Speed) + (RouteLenStorage / Speed) * ToolFactor);		
	}
	if ( (LoadB > Volume * Qty) & (LoadCap - Load < LoadB + LoadE) ) 
	{
		Bid = 0;
	}	
	if ( (LoadB <= Volume * Qty) & (LoadCap - Load >= Volume * Qty + LoadE) )
	{
		-+loadExpected(Volume * Qty + LoadE);
		Bid = math.round((RouteLenWorkshop / Speed) + (RouteLenShop / Speed) + (RouteLenStorage / Speed) * ToolFactor);
	}
	if ( (LoadB <= Volume * Qty) & (LoadCap - Load < Volume * Qty + LoadE) )
	{
		Bid = 0;
	}
	.	