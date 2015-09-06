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
	Bid = MaxBid-1;
	+bid(JobId,Bid,Items,StorageId);
	.
	
@pricedJob[atomic]
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: not working(_,_,_) & not jobDone(JobId) & not pricedJob(JobId,Items,StorageId)
<- 
	.print("New priced job: ",JobId," Items: ",Items, " Storage: ", StorageId);
	!separate_tasks(Items,JobId,StorageId,true);
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