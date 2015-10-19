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
	
+!get_tools
	: role(_, _, _, _, Tools) & shopList(List)
<-
	for ( .member(Tool,Tools) )
	{
		?product(Tool,Volume,BaseList);
		if (BaseList == [])
		{
			?find_shops(Tool,List,Result);
			?best_shop(Result,Shop);
			+buyList(Tool,1,Shop);
		}
		else
		{
			.print("Decomposing tool ",Tool);
			!decomp(BaseList);
			?baseListJob(Items);
			-baseListJob(_);
			for ( .member(item(ItemId,Qty),Items) )
			{
				?find_shops(ItemId,List,Result);
				?best_shop(Result,Shop);
				if (buyList(ItemId,Qty2,Shop))
				{
					-buyList(ItemId,Qty2,Shop);
					+buyList(ItemId,Qty+Qty2,Shop);			
				} else {
					+buyList(ItemId,Qty,Shop);		
				}	
			}
			?workshopList(WList);
			?closest_facility(WList, Workshop);
			+assembleList(Tool,Workshop);
		}
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