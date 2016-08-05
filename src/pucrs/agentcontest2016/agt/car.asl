!start.

+!start
	: true
<-
 	.wait({ +step(_) });
 	!go_nearest_shop;
 	+free;
    .
	
/*
+!start
	: true
<-
 	.wait({ +step(_) });
	!find_tools;
	!get_tools;
	+free;
	.
*/