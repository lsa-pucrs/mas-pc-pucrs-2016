items_has_price([item(NItem,Price,Qty,Load)]):- Price\==0.
items_has_price([item(NItem,Price,Qty,Load)|L]):- Price\==0.

auction_gain(Cost,Bid,MaxBid,WorkshopFee,BatteryFee):- Bid =  MaxBid*30/100 + Cost + WorkshopFee + BatteryFee. // % profit of 30% + expenses

calculateBid(Items,Bid,MaxBid,WorkshopFee,BatteryFee):- calculateCost(Items,Cost) & auction_gain(Cost,Bid,MaxBid,WorkshopFee,BatteryFee).

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
	: not working(_,_,_) & not jobDone(JobId) & not auctionJob(JobId,Items,StorageId) & not bid(JobId,Bid,Items,StorageId,MaxBid) & workshopPrice(Price) & workshopList(WList) & .nth(0,WList,Workshop) & shopsList(SList) & .nth(0,SList,shop(ShopId,_)) & roled(_, Speed, _, _, _) & chargingPrice(PriceC,Rate)
<- 
	+count_comp(0);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!count_composite(ItemId,Qty,BaseList);
	}
	?count_comp(NumberOfComp);
	-count_comp(NumberOfComp);
	?closestFacility([Workshop], FacilityA, RouteLenWorkshop);
	?closestFacility([ShopId], FacilityB, RouteLenShop);
	?closestFacility([StorageId], FacilityC, RouteLenStorage);	
	?calculateBid(Items,Bid,MaxBid,NumberOfComp*Price,math.round((RouteLenWorkshop / Speed * 10) + (RouteLenShop / Speed * 10) + (RouteLenStorage / Speed * 10) / Rate) * PriceC);
	if (Bid > MaxBid)
	{
		.print("Ignoring auction job ",JobId," since our bid of ",Bid," is higher then the max bid of ",MaxBid);
		+auctionJob(JobId,Items,StorageId);
	}
	else {
		+bid(JobId,Bid,Items,StorageId,MaxBid);		
	}
	.

// got an auction too soon, do not have lists ready yet just make a simple bid
@auctionJob2[atomic]
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: not working(_,_,_) & not jobDone(JobId) & not auctionJob(JobId,Items,StorageId) & not bid(JobId,Bid,Items,StorageId,MaxBid) & workshopPrice(Price)
<- 
	+count_comp(0);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!count_composite(ItemId,Qty,BaseList);
	}
	?count_comp(NumberOfComp);
	-count_comp(NumberOfComp);
	?calculateBid(Items,Bid,MaxBid,NumberOfComp*Price,1);
	if (Bid > MaxBid)
	{
		.print("Ignoring auction job ",JobId," since our bid of ",Bid," is higher then the max bid of ",MaxBid);
		+auctionJob(JobId,Items,StorageId);
	}
	else {
		+bid(JobId,Bid,Items,StorageId,MaxBid);		
	}
	.
	
@pricedJob[atomic]
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: not working(_,_,_) & not jobDone(JobId) & not pricedJob(JobId,Items,StorageId)
<- 
	.print("New priced job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	!separate_tasks(Items,JobId,StorageId,true);
	.	
	
@basesPrice	
+shop(Name,Lat,Long,Items)
	: items_has_price(Items)
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
		award(BidId,CNPBoardName,item(Task,1),JobId,StorageId)[artifact_name(CNPBoardName)];
		-listBids(_);
	}
	else {
		.print("No bids.");
	}
	clear(Task);
	.
	
@count_composite[atomic]
+!count_composite(ItemId,Qty,BaseList)
	: true 
<- 
	if (BaseList \== []) 
	{
		for ( .range(I,1,Qty) ) 
		{
			?count_comp(NumberOfComp);
			-+count_comp(NumberOfComp+1);			
			for ( .member(consumed(ItemId2,Qty2),BaseList) )
			{
				?product(ItemId2,Volume2,BaseList2);
				!count_composite(ItemId2,Qty2,BaseList2);
			}
		}
	}
	.
	
@materialsPrice
+!calculate_materials_prices
	: product(IdProd, Vol, BaseList) & BaseList \== [] & not(item_price(IdProd,_)) 
<- 
	for (.member(consumed(ItemIdBase,QtyBase),BaseList) & item_price(ItemIdBase,PriceBase))
	{
		if (not(item_price(IdProd,_)))
		{
			+item_price(IdProd,PriceBase * QtyBase);	
		} 
		else
		{
			?item_price(IdProd,PriceProd);
	 		-item_price(IdProd,PriceProd);
	 		+item_price(IdProd,PriceProd + PriceBase * QtyBase);	
		} 			
	}
	!!calculate_materials_prices;
	.
	
@materialsPrice2	
+!calculate_materials_prices.