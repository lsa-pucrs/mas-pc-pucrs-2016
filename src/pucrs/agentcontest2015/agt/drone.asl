!start.

+!start
	: true
<-
 	.wait({ +step(_) });
	!find_tools;
	!get_tools;
	+free;
	.

+step(Step)
	: Step mod 30 == 0
<-
	.suspend(start);
	!post_auction;
	.resume(start);
	.