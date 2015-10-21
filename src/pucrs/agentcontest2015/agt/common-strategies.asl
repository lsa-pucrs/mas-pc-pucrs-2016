!start.

+!start
	: true
<-
 	.wait({ +step(_) });
	!get_tools;
	for ( buyList(Tool,Qty,Shop) )
	{ 
		!goto(Shop);
		for ( buyList(Tool2,Qty2,Shop) )
		{
			!buy(Tool2,Qty2);	
		}
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