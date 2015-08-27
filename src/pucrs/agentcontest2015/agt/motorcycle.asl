+jobTaken(JobId)
	: auctionJob(JobId,Items,StorageId) & not working(_,_,_) & not jobDone(JobId)
<-
	.print("We won the auction for job ",JobId,"!");
	-auctionJob(JobId,Items,StorageId);
	!decomp(JobId,Items,StorageId);
	.

@auctionJob[atomic]
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: not working(_,_,_) & not jobDone(JobId) & not auctionJob(JobId,Items,StorageId)
<- 
	Bid = 1000;
	+bid(JobId,Bid,Items,StorageId);
	.
	
@pricedJob[atomic]
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: not working(_,_,_) & not jobDone(JobId)
<- 
	.print("New priced job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	!decomp(JobId,Items,StorageId);
	.	

+working(JobId,Items2,StorageId)
	: shopsList(List) & baseListJob(Items)
<-
	//-baseListJob(_);	
	for ( .member(item(ItemId,Qty),Items) )
	{
		?findShops(ItemId,List,[],Result);
		//.print("Shops with item ",ItemId,": ",Result);
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

@decomp
+!decomp(JobId,Items,StorageId)
	: true
<-
	+baseListJob([]);
	for ( .member(item(ItemId,Qty),Items) )
	{
		?product(ItemId,Volume,BaseList);
		!decomp_2(ItemId,Qty,BaseList);
	}		
	+working(JobId,Items,StorageId);
	.
	
@atomic	
+!decomp_2(ItemId,Qty,BaseList)
	: true 
<- 
	if (BaseList == []) {
			?baseListJob(List2);
			-+baseListJob([item(ItemId,Qty)|List2]);
	} else {
			for ( .range(I,1,Qty) ) {
				?assembleList(ListAssemble);
				-+assembleList([ItemId|ListAssemble]);				
				for ( .member(consumed(ItemId2,Qty2),BaseList) )
				{
					?product(ItemId2,Volume2,BaseList2);
					if (BaseList2 \== [])
					{
						?auxList(Aux);
						-+auxList([item(ItemId2,Qty2)|Aux]);						
					}
					!decomp_2(ItemId2,Qty2,BaseList2);
				}
			}
	}.