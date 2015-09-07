+task(Task,CNPBoard) 
	: true & .my_name(N) & N \== vehicle1
<- 
	.print("Found a task: ",Task);
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
	!make_bid(Task,BoardId);
	.
	
+winner(BidId,Items,JobId,StorageId) 
	: my_bid(BidId)
<- 
	.print("Awarded!.");
	+noBids;
	!decomp([Items]);
	+working(JobId,[Items],StorageId);
	.
	
+winner(BidId,Items,JobId,StorageId) 
	: my_bid(X) & not my_bid(BidId) & .my_name(N) & N \== vehicle1
<- 
	.print("Not awarded.");
	.
	
+!make_bid(Task,BoardId)
	: not noBids
<- 
	!create_bid(Task,Bid);
	bid(Bid,BidId)[artifact_id(BoardId)];
	+my_bid(BidId);
	.print("Bid submitted: ",Bid," - id: ",BidId);
	.
-!make_bid(Task,BoardId)
	: noBids
<- 
	.print("No more bids for me.");
	.
-!make_bid(Task,BoardId)
<- 
	.print("Too late for submitting the bid.");
	.drop_all_intentions;
	.
	
+!create_bid(Task,Bid)
	: max_bid_time(Timeout)
<- 
	Bid = math.round(math.random(Timeout));
	.	