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
	: storageList([StorageId|_]) & steps(Steps) & activePricedSteps(Active)
<-
	 !post_job_priced(Active, Steps, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	 .
	 
+!post_auction
	: storageList([StorageId|_]) & rewardAuction(Reward) & fineAuction(Fine) & activeAuctionSteps(Active) & auctionSteps(ActiveAuction)
<-
	 !post_job_auction(Reward, Fine, Active, ActiveAuction, StorageId, [item(base1,1), item(material1,2), item(tool1,3)]);
	 .
	 
+!go_work(JobId,StorageId)
	: buyList(Item,Qty,ShopId)
<-
	!goto(ShopId);
	while ( buyList(Item,Qty,ShopId) ) {
		!buy(Item,Qty);
		.wait(500);
	}
	!goto(StorageId);
	!deliver_job(JobId);
	.send(vehicle1,tell,done);
	-noMoreTasks;
	+free;
	.
	
+!go_charge
	:  chargingList(List) & closest_facility(List, Facility)
<-
	.print("**** Going to charge my battery at ", Facility);
	!goto(Facility);
	!charge;
	.

+free
	: true
<-
	while ( free )
	{
		!skip;
	}
	.
/*
+!go_nearest_shop
	: shopList(List) & closest_facility(List, Facility)
<-
	!goto(Facility);
	?step(S);
	.print("I have arrived at ", Facility, "   -   Step: ",S);
	.	
 */