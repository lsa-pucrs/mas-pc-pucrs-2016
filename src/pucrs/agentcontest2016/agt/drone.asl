!start.

+!start
	: true
<-
 	.wait({ +step(_) });
 	!go;
    .
 
+!go
	: true
<-
    !goto(shop1);
    !goto(shop2);
    !go;
	.

/* 
+!start
	: true
<-
 	.wait({ +step(_) });
	//!find_tools;
	//!get_tools;
	+free;
	.

+step(Step)
	: Step mod 30 == 0
<-
	!suspend;
	!post_auction;
	!resume;
	.
*/