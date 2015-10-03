+lastStep(Step)
	: Step == 1 | Step mod 30 == 0
<-
	+post_job_auction(500000, 5000, 1, 10, storage1, .list(item(base1,10)));
	.