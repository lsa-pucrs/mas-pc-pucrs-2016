+lastStep(Step)
	: Step mod 30 == 0  & storageList([StorageId|_])
<-
	+post_job_auction(500000, 5000, 1, 3, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	.
	
+auctionJob(JobId, StorageId, Begin, End, Fine, MaxBid, Items)
	: JobActive = End-Begin & .sort(Items,ItemsS) & .concat(StorageId,JobActive,Fine,MaxBid,ItemsS,String1) & post_job_auction(MaxBid2, Fine2, JobActive2, AuctionActive, StorageId2, Items2) & .sort(Items2,Items2S) & .concat(StorageId2,JobActive2,Fine2,MaxBid2,Items2S,String2) & String1 == String2
<-
	-post_job_auction(MaxBid2, Fine2, JobActive2, AuctionActive, StorageId2, Items2)
	.