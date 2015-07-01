!register.

+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: true
<-
	+job(JobId, StorageId, Items);
	.
	
+shop(ShopId, Lat, Lng, Items)
	: true
<-
	-shop(ShopId, _);
	+shop(ShopId, Items);
	.

+!select_goal
	: commit(JobId) & job(JobId, _, Items)
<-
	!fetch_items(Items)
	.
	
+!fetch_items([Item|Tails])
	: true
<-
	!fetch_items(Item);
	!fetch_items(Tails);
	.	

+!fetch_items([]) <- true.
	
+!fetch_items(item(ItemId, Quantity))
	: not has(ItemId)// & shop(ShopId, [item(ItemId)])
<-
	.findall(X, shop(X, [item(ItemId)]), Ids);
	.print(Ids);
	.print("Will go for item: ", ItemId);
	.
	
+!fetch_items(item(ItemId, Quantity))
	: not has(ItemId)
<-
	.print("No shop for item ", ItemId);
	.
	
//+!fetch_items(Item)
//	: not has(Item) & shop(ShopId, _, _, [availableItem(Item, Quantity, Price)])
//<-
//	true
//	.
	
+!select_goal
	: not commit(_) & job(JobId, StorageId, Items)
<-
	.print("Lemme get this job:", JobId);
	.print("Jobs with itens: ", Items);
	+commit(JobId);
	.

+!select_goal
	: not commit(_)
<-
	.print("Waiting for job!");
	!skip;
	.

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.
