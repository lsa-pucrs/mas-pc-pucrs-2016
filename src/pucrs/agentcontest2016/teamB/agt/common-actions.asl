// Goto (option 1)
// FacilityId must be a string
+!goto(FacilityId)
	: inFacility(FacilityId)
<-
	true
.

+!goto(FacilityId)
	: going(FacilityId)
<-
//	!continue;
	!commitAction(
		goto(
			facility(FacilityId)
		)
	);
.

+!goto(FacilityId)
	: not inFacility(FacilityId)
<-
	!commitAction(
		goto(
			facility(FacilityId)
		)
	);
	+going(FacilityId);
.

// Goto (option 2)
// Lat and Lon must be floats
+!goto(Lat, Lon)
	: true // TODO context must test battery and if [Id_lat, Id_Lon] != [self.lat, self.lon]
<-
	!commitAction(
		goto(
			lat(Lat),
			lon(Lon)
		)
	);
	+going;
	.

// Buy
// ItemId must be a string
// Amount must be an integer
+!buy(ItemId, Amount)
	: true // TODO check if there is enough capacity to load items
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
	: true // TODO test receiver position
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
	: true // TODO test giver position
<-
	!commitAction(
		receive
	);
	.

// Store
// ItemId must be a string
// Amount must be an integer
+!store(ItemId, Amount)
	: true // TODO check if current location is a storage and item * amount is with agent
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
	: true // TODO check if current location is a storage and if item * amount is there
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
	: true // TODO check if current location is a storage and if item * amount is there
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
	: true // TODO check if current location is a dump location and item * amount is with agent
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
	: true // TODO check if current location is a workshop
	// TODO remember that an assistant may be required to obtain items and tools
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
	: true // TODO check if current location is a workshop
	// TODO remember that an assembler may be required to obtain items and tools
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
	: true // TODO check if current location is the storage to deliver to
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
	: true // TODO check if battery is low, current location is a charging station and there is space
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
			storage(StorageId)
			// TODO items: custom parse
			// [item(id(item_id1), amount(10)), ... ]
		)
	);
	.

// Post job (option 2)
// Price must be an integer
// ActiveSteps must be an integer
// StorageId must be a string
// Items must be a string "item1=item_id1 amount1=10 item2=item_id2 amount2=5 ..."
+!post_job_priced(Price, ActiveSteps, StorageId, Items)
	: true
<-
	!commitAction(
		post_job(
			type(priced),
			price(Price),
			active_steps(ActiveSteps), 
			storage(StorageId)
			// TODO items: custom parse
			// [item(id(item_id1), amount(10)), ... ]
		)
	);
	.

// Continue
// No parameters
+!continue
	: true // TODO check if already charging or going
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
@commitAction[atomic]
+!commitAction(Action) : true 
<- 
	.my_name(Ag);
	cartago.invoke_obj("pucrs.agentcontest2016.teamB.env.EISArtifact", action(Ag, Action));
	.
