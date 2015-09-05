
items_has_price([item(NItem,Price,Qty,Load)]):- Price\==0.
items_has_price([item(NItem,Price,Qty,Load)|L]):- Price\==0.

auction_gain(Cost,Bid,MaxBid,WorkshopFee):- Bid =  MaxBid*30/100 + Cost + WorkshopFee. // % profit of 30% + expenses

calculateBid(Items,Bid,MaxBid,WorkshopFee):- calculateCost(Items,Cost) & auction_gain(Cost,Bid,MaxBid,WorkshopFee).

calculateCost([],Cost):- Cost = 0.
calculateCost([item(Id,Qty)],Cost):- 	item_price(Id,Price) &  Cost = Price * Qty.
calculateCost([item(Id,Qty)|L],Cost):- 	item_price(Id,Price) &  Temp = Price * Qty & calculateCost(L,Temp2) & Cost = Temp + Temp2.
										

@jobTaken[atomic]
+jobTaken(JobId)
	: auctionJob(JobId,Items,StorageId) & not working(_,_,_) & not jobDone(JobId)
<-
	.print("We won the auction for job ",JobId,"!");
	-auctionJob(JobId,Items,StorageId);
	!decomp(Items);
	+working(JobId,Items,StorageId);
	.

@auctionJob[atomic]
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
	?calculateBid(Items,Bid,MaxBid,NumberOfComp*Price);
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
	: not working(_,_,_) & not jobDone(JobId)
<- 
	.print("New priced job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	!decomp(Items);
	+working(JobId,Items,StorageId);
	.	

+working(JobId,Items2,StorageId)
	: shopsList(List) & baseListJob(Items)
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