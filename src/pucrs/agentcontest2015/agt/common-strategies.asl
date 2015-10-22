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
	
+!post_priced
	: storageList([StorageId|_]) & steps(Steps)
<-
	 !post_job_priced(1, Steps, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	 .
	 
+!post_auction
	: storageList([StorageId|_])
<-
	 !post_job_auction(500000, 5000, 1, 3, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	 . 

+free
	: true
<-
	while ( free )
	{
		!skip;
	}
	.