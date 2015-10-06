auction_gain(Cost,Bid,MaxBid,WorkshopFee,BatteryFee):- Bid =  MaxBid*30/100 + Cost + WorkshopFee + BatteryFee. // % profit of 30% + expenses

calculateBid(Items,Bid,MaxBid,WorkshopFee,BatteryFee):- calculateCost(Items,Cost) & auction_gain(Cost,Bid,MaxBid,WorkshopFee,BatteryFee).

calculateCost([],Cost):- Cost = 0.
calculateCost([item(Id,Qty)],Cost):- 	item_price(Id,Price) &  Cost = Price * Qty.
calculateCost([item(Id,Qty)|L],Cost):- 	item_price(Id,Price) &  Temp = Price * Qty & calculateCost(L,Temp2) & Cost = Temp + Temp2.

@jobTaken[atomic]
+jobTaken(JobId)
	: auctionJob(JobId,Items,StorageId) & not working(_,_,_)
<-
	.print("We won the auction for job ",JobId,"!");
	-auctionJob(JobId,Items,StorageId);
	!separate_tasks(Items,JobId,StorageId);
	.

@auctionJob[atomic]
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: not working(_,_,_) & not auctionJob(JobId,Items,StorageId) & not bid(JobId,Bid,Items,StorageId,MaxBid) & workshopPrice(Price) & workshopList([Workshop|_]) & shopsList([shop(ShopId,_)|_]) & roled(_, Speed, _, _, _) & chargingPrice(PriceC,Rate) & item_price(_,_)  & lastStep(Step)
<- 
	.print("New auction job: ",JobId," Items: ",Items, " Storage: ", StorageId, " End: ",End);

	+count_comp(0);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!count_composite(ItemId,Qty,BaseList);
	}
	?count_comp(NumberOfComp);
	-count_comp(NumberOfComp);
	
	?closest_facility_drone([Workshop], FacilityD, RouteLenWorkshopDrone);
	?closest_facility_drone([ShopId], FacilityE, RouteLenShopDrone);
	?closest_facility_drone([StorageId], FacilityF, RouteLenStorageDrone);
	if (math.round(RouteLenWorkshopDrone/5+RouteLenShopDrone/5+RouteLenStorageDrone/5) >  End-Step)
	{
		.print("Ignoring auction job ",JobId," deadline is too short.");
		+auctionJob(JobId,Items,StorageId);
	}
	else {
		?closest_facility([Workshop], FacilityA, RouteLenWorkshop);
		?closest_facility([ShopId], FacilityB, RouteLenShop);
		?closest_facility([StorageId], FacilityC, RouteLenStorage);	
		?calculateBid(Items,Bid,MaxBid,NumberOfComp*Price,math.round((RouteLenWorkshop / Speed * 10) + (RouteLenShop / Speed * 10) + (RouteLenStorage / Speed * 10) / Rate) * PriceC);
		if (Bid > MaxBid)
		{
			.print("Ignoring auction job ",JobId," either our bid of ",Bid," is higher then the max bid of ",MaxBid," or it has a short deadline");
			+auctionJob(JobId,Items,StorageId);
		}
		else {
			+bid(JobId,Bid,Items,StorageId,MaxBid);		
		}				
	}
	.
	
/* 
// got an auction too soon, do not have item prices ready yet just make a simple bid
@auctionJob2[atomic]
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: not working(_,_,_) & not auctionJob(JobId,Items,StorageId) & not bid(JobId,Bid,Items,StorageId,MaxBid) & workshopPrice(Price) & workshopPrice(Price) & workshopList([Workshop|_]) & shopsList([shop(ShopId,_)|_]) & roled(_, Speed, _, _, _) & chargingPrice(PriceC,Rate)
<- 
	+count_comp(0);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!count_composite(ItemId,Qty,BaseList);
	}
	?count_comp(NumberOfComp);
	-count_comp(NumberOfComp);
	?closest_facility([Workshop], FacilityA, RouteLenWorkshop);
	?closest_facility([ShopId], FacilityB, RouteLenShop);
	?closest_facility([StorageId], FacilityC, RouteLenStorage);
	?auction_gain(0,Bid,MaxBid,NumberOfComp*Price,math.round((RouteLenWorkshop / Speed * 10) + (RouteLenShop / Speed * 10) + (RouteLenStorage / Speed * 10) / Rate) * PriceC);
	if (Bid > MaxBid)
	{
		.print("Ignoring auction job ",JobId," since our bid of ",Bid," is higher then the max bid of ",MaxBid);
		+auctionJob(JobId,Items,StorageId);
	}
	else {
		+bid(JobId,Bid,Items,StorageId,MaxBid);		
	}
	.
*/	
@pricedJob[atomic]
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: not working(_,_,_) & not pricedJob(JobId,Items,StorageId) & maxBidders(Max) & not cnp(_) & lastStep(Step) & workshopList([Workshop|_]) & shopsList([shop(ShopId,_)|_])
<- 
	.print("New priced job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	
	?closest_facility_drone([Workshop], FacilityA, RouteLenWorkshop);
	?closest_facility_drone([ShopId], FacilityB, RouteLenShop);
	?closest_facility_drone([StorageId], FacilityC, RouteLenStorage);
	
	if (math.round(RouteLenWorkshop/5+RouteLenShop/5+RouteLenStorage/5) >  End-Step)
	{
		.print("Ignoring priced job ",JobId," even in the best case scenario we would not be able to complete it.");
		+pricedJob(JobId,Items,StorageId);
	}
	else {
	if ( .length(Items,NumberTasks) &  NumberTasks <= Max)
	{
		!separate_tasks(Items,JobId,StorageId);
	}
	else {
		.print("Too many tasks, not enough agents!");
	}
	}
	.	

+!create_taskboard
	: true
<-
	makeArtifact("task_board","pucrs.agentcontest2015.cnp.TaskBoard",[]);
	.print("Created taskboard.");
	.

+!separate_tasks(Items,JobId,StorageId)
	: max_bid_time(Time)
<-
	for ( .member(item(ItemId,Qty),Items) )
	{
		!!allocate_task(item(ItemId,Qty),Time,Items,JobId,StorageId);
	}
	.
	
+!allocate_task(item(ItemId,Qty),Timeout,Items,JobId,StorageId)
	: true
<- 
	announce(item(ItemId,Qty),Timeout,CNPBoardName);
	+cnp(CNPBoardName);
	.print("Announced: ",Qty,"x of ",ItemId," on ",CNPBoardName);
	getBids(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0)
	{		
		+pricedJob(JobId,Items,StorageId);
		.print("Got bids (",.length(Bids),") for task ",CNPBoardName," List ",Bids);
		?select_bid(Bids,bid(99999,99999),bid(Bid,BidId));
		.print("Bid that won: ",Bid," Bid id: ",BidId);
		award(BidId,CNPBoardName,item(ItemId,Qty),JobId,StorageId)[artifact_name(CNPBoardName)];
		-listBids(CNPBoardName,_);
	}
	else {
		.print("No bids.");
	}
	-cnp(CNPBoardName);
	clear(CNPBoardName);
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