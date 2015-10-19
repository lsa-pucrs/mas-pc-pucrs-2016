!start.

+!start
	: true
<-
	.wait({ +step(_) });
	!get_tools;
	for ( buyList(Tool,Qty,Shop) )
	{ 
		!goto(Shop);
		!buy(Tool,Qty);
	}
	+free;
	.

+free
	: true
<-
	while ( free )
	{
		!skip;
	}
	.