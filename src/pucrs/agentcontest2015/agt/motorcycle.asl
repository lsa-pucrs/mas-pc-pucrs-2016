!start.

+!start
	: true
<-
 	.wait({ +step(_) });
 	!post_priced;
	!find_tools;
	!get_tools;
	+free;
	.

/* +lastStep(Step)
	: Step mod 30 == 0 & storageList([StorageId|_]) & steps(Steps)
<-
	+post_job_priced(1, Steps, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	.
	
+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: compare_jobs(JobId, StorageId, Begin, End, Reward, Items)
<-
	-post_job_priced(Reward2, JobActive2, StorageId2, Items2);
	.
	*/