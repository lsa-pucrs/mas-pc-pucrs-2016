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
	: not working(_,_,_) & not jobDone(JobId) & not auctionJob(JobId,Items,StorageId)
<- 
	Bid = MaxBid-1;
	+bid(JobId,Bid,Items,StorageId);
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