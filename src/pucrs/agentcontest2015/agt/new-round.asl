+lastStep(Step)
	: Step == 0 & tools(Tools) & compositeMaterials(CompositeList)
<-
	!checkTools(Tools);
	!makeCompositeList;
	.

+!new_round(Role, Speed, LoadCap, BatteryCap, Tools)
	: true
<-
	+free;
	+max_bid_time(1000);
	+compositeMaterials([]);			// criada para auxiliar o assist job
	+chargingList([]);
	+dumpList([]);
	+shopsList([]);
	+workshopList([]);
	+assembleList([]);
	+verifyItems([]);
	+auxList([]);                    // lista para limpar as bases compostas
	+tools(Tools);
	+chargeTotal(BatteryCap);
	+loadTotal(LoadCap);
	.

+!checkTools(Tools)
	: shopsList(List)
<-
	for ( .member(Tool,Tools))
	{
		?product(Tool,Volume,BaseList);
		if (BaseList \== []) 
		{
			.print("Decomposing tool ",Tool);
			!decomp(BaseList);
			?baseListJob(Items);
			-baseListJob(_);
			for ( .member(item(ItemId,Qty),Items) )
			{
				?findShops(ItemId,List,[],Result);
				?bestShop(Result,Shop);
				if (buyList(ItemId,Qty2,Shop))
				{
					-buyList(ItemId,Qty2,Shop);
					+buyList(ItemId,Qty+Qty2,Shop);			
				} else {
					+buyList(ItemId,Qty,Shop);		
				}	
			}
			?assembleList(ListAssemble);
			-+assembleList([Tool|ListAssemble]);
			-tools(Tools);
			.delete(Tool,Tools,ToolsNew);
			+tools(ToolsNew);						
		}
	}
	.

@makeCompositeList[atomic]	
+!makeCompositeList
	: true
<-
	for (product(ProductId, Volume, BaseList)) 
	{
		if (BaseList \== [])
		{
			?compositeMaterials(CompositeList);
			-+compositeMaterials([ProductId|CompositeList]);
		}
	}
	.	