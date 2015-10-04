+lastStep(Step)
	: Step == 1 | Step mod 31 == 0
<-
	+post_job_auction(500000, 5000, 3, 1, storage1, .list(item(base1,10)));
	.