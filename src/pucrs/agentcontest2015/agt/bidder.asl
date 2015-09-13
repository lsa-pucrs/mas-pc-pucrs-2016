@task[atomic]
+task(Task,CNPBoard) 
	: roled(Role, Speed, LoadCap, BatteryCap, Tools) & Role \== "Truck"
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
+winner(BidId,Task,Items,JobId,StorageId) 
	: my_bid(X,Y) & not my_bid(BidId,Task)
<- 
	.print("Not awarded.");
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
	
+!create_bid(Task,Bid)
	: max_bid_time(Timeout)
<- 
	Bid = math.round(math.random(Timeout));
	.	