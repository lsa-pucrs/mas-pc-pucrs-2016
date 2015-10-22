+!get_tools
	: true
<-
	!buy_items;
	!assemble_items;
	.
	
+!buy_items
	: true
<-
	for ( buyList(Tool,Qty,Shop) )
	{ 
		!goto(Shop);
		while ( buyList(Tool2,Qty2,Shop) )
		{
			!buy(Tool2,Qty2);	
		}
	}
	.	

+!assemble_items
	: true
<-
	while ( assembleList(Tool,Workshop) )
	{
		!goto(Workshop);
		!assemble(Tool);
	}
	.

+free
	: true
<-
	while ( free )
	{
		!skip;
	}
	.