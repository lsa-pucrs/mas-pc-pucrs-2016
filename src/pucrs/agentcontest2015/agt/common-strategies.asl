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
	for ( assembleList(Tool,Workshop) )
	{
		!goto(Workshop);
		!assemble(Tool);
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