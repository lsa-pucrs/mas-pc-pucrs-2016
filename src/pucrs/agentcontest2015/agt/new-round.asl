+!new_round(Role, Speed, LoadCap, BatteryCap, Tools)
	: true
<-
	+chargingList([]);
	+shopsList([]);
	+workshopList([]);
	+assembleList([]);
	+verifyItems([]);
	+auxList([]);                    // lista para limpar as bases compostas
	+tools(Tools);
	+chargeTotal(BatteryCap);
	+loadTotal(LoadCap);
	.wait(500);
	!checkTools(Tools);
	.

//@checkTools[atomic]
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