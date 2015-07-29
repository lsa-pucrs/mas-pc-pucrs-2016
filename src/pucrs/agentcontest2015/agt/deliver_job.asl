+pricedJob(JobId, StorageId, Begin, End, Reward, Items)
	: true
<-
	+job(JobId, StorageId, Items);
	.print(" ## new job");
	.
	
+shop(ShopId, Lat, Lng, Items)
	: true
<-
	-shop(ShopId, _);
	+shop(ShopId, Items);
	.
//+lastActionResult(X) <- .print("-- >> LastAction Result:", X).	
//+lat(X) <- .print("Latitude: ", X).
//+lon(X) <- .print("Longitude: ", X).
	
+inFacility(X)[artifact_id(_)]
	: going(L) & X == L 
<- 
	if (going(L) & X == L) {
		-going(L);
	};
	-+inFacility(X);
	.

//atPlace(Lat,Lng):- lat(Lat) & lon(Lng).
	
has_items(JustOne) :- true. // implementar isso
has_items([First|Others]) :- true. // implementar isso -- checar se tem todos os items da lista

+!select_goal 
	: going(L) 
<-
	.print("Continuing to location ",L); 
	!goto(L);
	.

//+!select_goal 
//	: going(Lat,Lng) & atplace(Lat,Lng)
//<-
//	.print("Arrived to ", Lat, Lng); 
//	-going(L);
//	.

//+!select_goal 
//	: going(Lat,Lng) & not atplace(Lat,Lng)
//<-
//	.print("Continuing to location ", Lat, Lng); 
//	!continue;
//	.

+!select_goal
	: commit(JobId) & job(JobId, StorangeId, Items) & has_items(Items) 
<-
	!deliver_job(JobId, StorangeId, Items);
	.
	
+!deliver_job(JobId, StorangeId, Items)
	: not inFacility(StorageId) 
<- 	
	.print("Going to facility: ", StorangeId);
	!goto(StorangeId);
	.

+!deliver_job(JobId, StorangeId, Items)
	: inFacility(StorangeId)
<-  
	.print("In facility: ", StorangeId, " -- deliver Job");
	!deliver_job(JobId);
	-commit(JobId);
	-job(JobId,StorangeId,Items);
	.wait(100);
	.

+!select_goal
	: not commit(_) & job(JobId, StorageId, Items)
<-
	.print("Lemme get this job:", JobId);
	.print("Location to deliver job:", StorageId);
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
