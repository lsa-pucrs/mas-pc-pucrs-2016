// Goto (option 1)
// FacilityId must be a string
+!goto(FacilityId)
    : true // TODO context must test battery and if [Id_lat, Id_Lon] != [self.lat, self.lon]
<-
    .concat("facility=", FacilityId, Param);
    action("goto", Param);
    //TODO +going(FacId_lat, FacId_Lon)
    .

// Goto (option 2)
// Lat and Lon must be floats
+!goto(Lat, Lon)
    : true // TODO context must test battery and if [Id_lat, Id_Lon] != [self.lat, self.lon]
<-
    .concat("lat=", Lat, " lon=", Lon, Param);
    action("goto", Param);
    //TODO +going(Lat, Lon)
    .

// Goto (option 3)
// No parameters
// TODO check if this option is going to be used
+!goto
    : going(Id_lat, Id_Lon) // TODO context must test battery and if [Id_lat, Id_Lon] != [self.lat, self.lon]
<-
    action("goto"); // TODO test action without extra parameters
    .

// Buy
// ItemId must be a string
// Amount must be an integer
+!buy(ItemId, Amount)
    : true // TODO check if there is enough capacity to load items
<-
    .concat("item=", ItemId, " amount=", Amount, Param);
    action("buy", Param);
    .

// Give
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!give(AgentId, ItemId, Amount)
    : true // TODO test receiver position
<-
    .concat("agent=", AgentId, " item=", ItemId, " amount=", Amount, Param);
    action("give", Param);
    .

// Receive
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!receive
    : true // TODO test giver position
<-
    action("receive"); // TODO test action without extra parameters
    .

// Store
// ItemId must be a string
// Amount must be an integer
+!store(ItemId, Amount)
    : true // TODO check if current location is a storage and item * amount is with agent
<-
    .concat("item=", ItemId, " amount=", Amount, Param);
    action("store", Param);
    .

// Retrieve
// ItemId must be a string
// Amount must be an integer
+!retrieve(ItemId, Amount)
    : true // TODO check if current location is a storage and if item * amount is there
<-
    .concat("item=", ItemId, " amount=", Amount, Param);
    action("retrieve", Param);
    .

// Retrieve delivered
// ItemId must be a string
// Amount must be an integer
+!retrieve_delivered(ItemId, Amount)
    : true // TODO check if current location is a storage and if item * amount is there
<-
    .concat("item=", ItemId, " amount=", Amount, Param);
    action("retrieve_delivered", Param);
    .

// Dump
// ItemId must be a string
// Amount must be an integer
+!dump(ItemId, Amount)
    : true // TODO check if current location is a dump location and item * amount is with agent
<-
    .concat("item=", ItemId, " amount=", Amount, Param);
    action("dump", Param);
    .

// Assemble
// ItemId must be a string
+!assemble(ItemId)
    : true // TODO check if current location is a workshop
    // TODO remember that an assistant may be required to obtain items and tools
<-
    .concat("item=", ItemId, Param);
    action("assemble", Param);
    .

// Assist assemble
// AgentId must be a string
+!assemble(AgentId)
    : true // TODO check if current location is a workshop
    // TODO remember that an assembler may be required to obtain items and tools
<-
    .concat("assembler=", AgentId, Param);
    action("assist_assemble", Param);
    .

// Deliver job
// JobId must be a string
+!deliver_job(JobId)
    : true // TODO check if current location is the storage to deliver to
<-
    .concat("job=", JobId, Param);
    action("deliver_job", Param);
    .

// Charge
// No parameters
+!charge
    : true // TODO check if battery is low, current location is a charging station and there is space
<-
    action("charge"); // TODO test action without extra parameters
    .

// Bid for job
// JobId must be a string
// Price must be an integer
+!bid_for_job(JobId, Price)
    : true
<-
    .concat("job=", JobId, " price=", Price, Param);
    action("bid_for_job", Param);
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
    .concat("type=auction max_price=", MaxPrice, " fine=", Fine, " active_steps=", ActiveSteps, " auction_steps=", AuctionSteps, " storage=", StorageId, " ",Items, Param);
    action("post_job", Param);
    .

// Post job (option 2)
// Price must be an integer
// ActiveSteps must be an integer
// StorageId must be a string
// Items must be a string "item1=item_id1 amount1=10 item2=item_id2 amount2=5 ..."
+!post_job_priced(Price, ActiveSteps, StorageId, Items)
    : true
<-
    .concat("type=priced price=", Price, " active_steps=", ActiveSteps, " storage=", StorageId, " ", Items, Param);
    action("post_job", Param);
    .

// Continue
// No parameters
+!continue
    : true // TODO check if already charging or going
<-
    action("continue"); // TODO test action without extra parameters
    .

// Skip
// No parameters
+!skip
    : true
<-
    action("skip"); // TODO test action without extra parameters
    .

// Abort
// No parameters
+!abort
    : true
<-
    action("abort"); // TODO test action without extra parameters
    .