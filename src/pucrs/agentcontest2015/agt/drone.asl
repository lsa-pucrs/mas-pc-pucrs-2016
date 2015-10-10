+lastStep(Step)
	: Step mod 30 == 0 & storageList([StorageId|_])
<-
	+post_job_auction(500000, 5000, 1, 3, StorageId, .list(item(base1,1), item(material1,2), item(tool1,3)));
	.