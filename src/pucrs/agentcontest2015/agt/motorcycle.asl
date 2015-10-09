/* 
+lastStep(Step)
	: (Step == 1 | Step mod 31 == 0) & storageList([StorageId|_]) & steps(Steps)
<-
	+post_job_priced(1, Steps, StorageId, .list(item(base1,1), item(material1,2), item(tool1,3)));
	.
*/