+lastStep(Step)
	: Step mod 30 == 0 & storageList([StorageId|_]) & steps(Steps)
<-
	+post_job_priced(1, Steps, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	.
	
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: JobActive = End-Begin & .sort(Items,ItemsS) & .concat(StorageId,JobActive,Reward,ItemsS,String1) & post_job_priced(Reward2, JobActive2, StorageId2, Items2) & .sort(Items2,Items2S) & .concat(StorageId2, JobActive2, Reward2, Items2S,String2) & String1 == String2
<-
	-post_job_priced(Reward2, JobActive2, StorageId2, Items2);
	.