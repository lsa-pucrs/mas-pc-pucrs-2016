items_has_price([item(NItem,Price,Qty,Load)]):- Price\==0.
items_has_price([item(NItem,Price,Qty,Load)|L]):- Price\==0.

aution_gain(Cost,Bid):- Bid = Cost * 10. // % lucro de 10 vezes o custo

calculateBid(Items,Bid):- calculateCost(Items,Cost) & aution_gain(Cost,Bid).

calculateCost([],Cost):- Cost = 0.
calculateCost([item(Id,Qty)],Cost):- 	item_price(Id,Price) &  Cost = Price * Qty.
calculateCost([item(Id,Qty)|L],Cost):- 	item_price(Id,Price) &  Temp = Price * Qty & calculateCost(L,Temp2) & Cost = Temp + Temp2.

@jobTaken[atomic]
+jobTaken(JobId)
	: auctionJob(JobId,Items,StorageId) & not working(_,_,_) & not jobDone(JobId)
<-
	.print("We won the auction for job ",JobId,"!");
	-auctionJob(JobId,Items,StorageId);
	!separate_tasks(Items,JobId,StorageId,false);
	.

@auctionJob[atomic]
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: not working(_,_,_) & not jobDone(JobId) & not auctionJob(JobId,Items,StorageId)
<- 
	?calculateBid(Items,Bid);
	+bid(JobId,Bid,Items,StorageId);
	.
	
@pricedJob[atomic]
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: not working(_,_,_) & not jobDone(JobId) & not pricedJob(JobId,Items,StorageId)
<- 
	.print("New priced job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	!separate_tasks(Items,JobId,StorageId,true);
	.	
	
@basesPrice	
+shop(Name,Lat,Long,Items): items_has_price(Items)
	<- 
	for(.member(item(NItem,Price,Qty,Load),Items))
	{
		if(not(item_price(NItem,Price2)) | (item_price(NItem,Price2) & Price > Price2))
		{
			-item_price(NItem,Price2);
			+item_price(NItem,Price);
		}		 
	}
	!!calculate_materials_prices;
	.	

+!create_taskboard
	: true
<-
	makeArtifact("task_board","pucrs.agentcontest2015.cnp.TaskBoard",[]);
	.print("Created taskboard.");
	.

+!separate_tasks(Items,JobId,StorageId,TestPriced)
	: true
<-
	for ( .member(item(ItemId,Qty),Items) )
	{
		for ( .range(I,1,Qty) ) {
			!allocate_task(ItemId,1000,Items,JobId,StorageId,TestPriced);
		}
	}
	.
	
+!allocate_task(Task,Timeout,Items,JobId,StorageId,TestPriced)
	: true
<- 
	announce(Task,Timeout,CNPBoardName);
	.print("Announced: ",Task," on ",CNPBoardName);
	getBids(Bids,BidsIds) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0)
	{		
		if (TestPriced)
		{
			+pricedJob(JobId,Items,StorageId);
		}
		+listBids([]);
		for (.range(I,0,.length(Bids)-1))
		{
			?listBids(List);
			.nth(I,Bids,MBid);
			.nth(I,BidsIds,MBidId);
			-+listBids([bid(MBid,MBidId)|List]);
		}
		?listBids(ListNew);
		.print("Got bids (",.length(Bids),")");
		?selectBid(ListNew,bid(99999,99999),bid(Bid,BidId));
		.print("Bid that won: ",Bid," Bid id: ",BidId);
		award(BidId,item(Task,1),JobId,StorageId)[artifact_name(CNPBoardName)];
		-listBids(_);
	}
	else {
		.print("No bids.");
	}
	clear(Task);
	.
	
@materialsPrice
+!calculate_materials_prices: product(IdProd, Vol, BaseList) & BaseList \== [] & not(item_price(IdProd,_)) 
	<- 
	for (.member(consumed(ItemIdBase,QtyBase),BaseList) & item_price(ItemIdBase,PriceBase)){
		if(not(item_price(IdProd,_)))
		{
			+item_price(IdProd,PriceBase * QtyBase);	
		}else{
			?item_price(IdProd,PriceProd);
	 		-item_price(IdProd,PriceProd);
	 		+item_price(IdProd,PriceProd + PriceBase * QtyBase);	
		} 			
	}
	!!calculate_materials_prices.
	
@materialsPrice2	
+!calculate_materials_prices.