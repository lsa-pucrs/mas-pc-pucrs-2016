+!get_tools
	: true
<-
	!buy_items;
	!assemble_items;
	.
	
+!buy_items
	: true
<-
	for ( buyList(Item,Qty,Shop) )
	{ 
		!goto(Shop);
		while ( buyList(Item2,Qty2,Shop) )
		{
			!buy(Item2,Qty2);	
		}
	}
	.	

+!assemble_items
	: true
<-
	while ( assembleList(Item,Workshop) )
	{
		!goto(Workshop);
		!assemble(Item);
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