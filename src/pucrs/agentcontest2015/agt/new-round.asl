+!new_round
	: true
<-
	+chargingList([]);
	+dumpList([]);
	+storageList([]);
	+shopList([]);
	+workshopList([]);
	.
	
+lastStep(Step)
	: Step == 1 & role(_, _, _, _, Tools) & shopList(List)
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

/* 
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
	+loadExpected(0);
	+maxBidders(4);
	+max_bid_time(500);
	+workshopPrice(0);
	+chargingPrice(0,0);
	+assembleToolsList([]);
	+compositeMaterials([]);			// criada para auxiliar o assist job
	+storeList([]);
	+retrieveList([]);
	+assembleList([]);
	+verify_items([]);
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
			?assembleToolsList(ListAssemble);
			-+assembleToolsList([Tool|ListAssemble]);
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
*/