// Goto (option 1)
// FacilityId must be a string
+!goto(FacilityId) : inFacility(FacilityId).

+!goto(_) 
	: lastActionResult(Result) & Result == failed_random & lastActionReal(Action) & .substring("goto",Action) & going(FacilityId)
<-
	!commitAction(goto(facility(FacilityId)));
	!goto(FacilityId);
	.
+!goto(FacilityId)
	: not going(FacilityId)
<-
	+going(FacilityId);
	!commitAction(goto(facility(FacilityId)));
	!goto(FacilityId);
	.

+!goto(FacilityId)
<-
	!continue;
	!goto(FacilityId);
	.

// Goto (option 2)
// Lat and Lon must be floats
+!goto(Lat, Lon)
	: true
<-
	!commitAction(
		goto(
			lat(Lat),
			lon(Lon)
		)
	);
	+going(Lat,Lon);
	.

// Buy
// ItemId must be a string
// Amount must be an integer
+!buy(ItemId, Amount)
	: true
<-
	!commitAction(
		buy(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Give
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!give(AgentId, ItemId, Amount)
	: true
<-
	!commitAction(
		give(
			agent(AgentId),
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Receive
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!receive
	: true
<-
	!commitAction(
		receive
	);
	.

// Store
// ItemId must be a string
// Amount must be an integer
+!store(ItemId, Amount)
	: true
<-
	!commitAction(
		store(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Retrieve
// ItemId must be a string
// Amount must be an integer
+!retrieve(ItemId, Amount)
	: true
<-
	!commitAction(
		retrieve(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Retrieve delivered
// ItemId must be a string
// Amount must be an integer
+!retrieve_delivered(ItemId, Amount)
	: true
<-
	!commitAction(
		retrieve_delivered(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Dump
// ItemId must be a string
// Amount must be an integer
+!dump(ItemId, Amount)
	: true
<-
	!commitAction(
		dump(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Assemble
// ItemId must be a string
+!assemble(ItemId)
	: true
<-
	!commitAction(
		assemble(
			item(ItemId)
		)
	);
	.

// Assist assemble
// AgentId must be a string
+!assist_assemble(AgentId)
	: true
<-
	!commitAction(
		assist_assemble(
			assembler(AgentId)
		)
	);
	.

// Deliver job
// JobId must be a string
+!deliver_job(JobId)
	: true
<-
	!commitAction(
		deliver_job(
			job(JobId)
		)
	);
	.

// Charge
// No parameters
+!charge
	: true
<-
	+charging;
	!commitAction(charge);
	.

// Bid for job
// JobId must be a string
// Price must be an integer
+!bid_for_job(JobId, Price)
	: true
<-
	!commitAction(
		bid_for_job(
			job(JobId),
			price(Price)
		)
	);
	.

// Post job (option 1)
// MaxPrice must be an integer
// Fine must be an integer
// ActiveSteps must be an integer
// AuctionSteps must be an integer
// StorageId must be a string
// Items must be a string "item1=item_id1 amount1=10 item2=item_id2 amount2=5 ..."
// Example: !post_job_auction(1000, 50, 1, 10, storage1, [item(base1,1), item(material1,2), item(tool1,3)]);
+!post_job_auction(MaxPrice, Fine, ActiveSteps, AuctionSteps, StorageId, Items)
	: true
<-
	!commitAction(
		post_job(
			type(auction),
			max_price(MaxPrice),
			fine(Fine),
			active_steps(ActiveSteps),
			auction_steps(AuctionSteps), 
			storage(StorageId),
			Items
		)
	);
	.

// Post job (option 2)
// Price must be an integer
// ActiveSteps must be an integer
// StorageId must be a string
// Items must be a string "item1=item_id1 amount1=10 item2=item_id2 amount2=5 ..."
// Example: !post_job_priced(1000, 50, storage1, [item(base1,1), item(material1,2), item(tool1,3)]);
+!post_job_priced(Price, ActiveSteps, StorageId, Items)
	: true
<-
	!commitAction(
		post_job(
			type(priced),
			price(Price),
			active_steps(ActiveSteps), 
			storage(StorageId),
			Items
		)
	);
	.

// Continue
// No parameters
+!continue
	: true
<-
	!commitAction(continue);
	.

// Skip
// No parameters
+!skip
	: true
<-
	!commitAction(skip);
	.

// Abort
// No parameters
+!abort
	: true
<-
	!commitAction(abort);
	.
 
+!commitAction(Action)
    : step(S)
<- 
	-+lastActionReal(Action);
	if (Action \== skip & Action \== continue) {
	    .print("Action: ",Action, "   -   Step: ",S);
    }	
	action(Action); // the action in the artifact
	.wait({ +step(_) }); // wait next step to continue
//	if (Action \== skip & not (lastActionResult(successful) | lastActionResult(successful_partial))) {
//		.print("step ",S,", error executing ", Action, " trying again...");
//		!commitAction(Action);
//	}  
	.

+!commitAction(Action)
    : not step(S) 
<- 
	.wait({ +step(_) }); // wait the first step to continue
	!commitAction(Action)  
	.