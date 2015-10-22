!start.

+!start
	: true
<-
 	.wait({ +step(_) });
	!find_tools;
	!get_tools;
	+free;
	.

/* +lastStep(Step)
	: Step mod 30 == 0  & storageList([StorageId|_])
<-
	+post_job_auction(500000, 5000, 1, 3, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	.
	
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: compare_jobs(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
<-
	-post_job_auction(MaxBid2, Fine2, JobActive2, AuctionActive, StorageId2, Items2)
	.
	*/