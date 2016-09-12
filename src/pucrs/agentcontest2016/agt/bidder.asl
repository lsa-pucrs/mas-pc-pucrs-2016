// PERIGO, AGENTES ESTÃO COMEÇANDO A DAR A BID ANTES DE TROCAREM DE PASSO
+task(Task,CNPBoard,StorageIdS,TaskId)
	: .my_name(Me) & Me == vehicle15
<- 
	-task(Task,CNPBoard,StorageIdS,TaskId);
  	.

+task(Task,CNPBoard,StorageIdS,TaskId)
<- 
//	.print("Starting my bid for task ",TaskId);
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
	.term2string(StorageId,StorageIdS);
  	!make_bid(Task,StorageId,BoardId,CNPBoard,TaskId);
  	.
	
+winner(List,JobId,StorageId,ShopId)
	: true
<- 
	.print("Awarded task to get ",List," at ",ShopId);
	for ( .member(item(ItemId,Qty),List) ) {
		+buyList(ItemId,Qty,ShopId);
	}
	!go_work(JobId,StorageId);
	.

+!make_bid(item(ItemId,Qty),StorageId,BoardId,CNPBoard,TaskId)
	: .my_name(Me)
<- 
	!create_bid(item(ItemId,Qty),StorageId,Bid,ShopId,TaskId);
	bid(Bid,Me,ShopId,item(ItemId,Qty))[artifact_id(BoardId)];
//	.print("Bid submitted: ",Bid," for task: ",CNPBoard," at shop ",ShopId);
	.
	
// Se o agente j� est� trabalhando em um job no pr�ximo job envia uma proposta zerada
+!create_bid(item(ItemId,Qty),StorageId,Bid,ShopId,TaskId)
	: winner(_,_,_,_)
<-
	Bid = -1;
	ShopId = shop0;
	.
+!create_bid(item(ItemId,Qty),StorageId,Bid,ShopId,TaskId)
	: product(ItemId, Volume, BaseList) & role(_, Speed, LoadCap, _, Tools) & load(Load) & shopList(List) 
<- 
	?find_shops(ItemId,List,ShopsViable);
	?closest_facility(ShopsViable, ShopId);
	?charge(Battery);
	+bid(0,TaskId);
	+chargeExp(0,TaskId);
	!calculate_route(ShopId,TaskId,Battery);
//	?route(ShopId, StorageId, RouteLenStorage);	
	?bid(BidAux,TaskId);
//	.print("Placing bid SHOP  ",BidAux);
	?chargeExp(NewBattery,TaskId);
	if (BidAux == -1) {
		Bid = -1;
		-chargeExp(NewBattery,TaskId);
		-bid(BidAux,TaskId);
	}
	else {
		!calculate_routeStorage(StorageId,ShopId,TaskId,NewBattery);
		?bid(BidAux2,TaskId);
		?chargeExp(NewBattery2,TaskId);
		-chargeExp(NewBattery2,TaskId);
		-bid(BidAux2,TaskId);
//		.print("Placing bid SHOP+STORAGE   ",BidAux2);
		if (BidAux2 == -1) {
			Bid = -1;
		}
		else {
			?calculate_bases_load(BaseList,Qty,0,LoadB);
			if ( (LoadB > Volume * Qty) & (LoadCap - Load >= LoadB) ) {
				Bid = BidAux2;
			//		Bid = math.round((RouteLenShop / Speed) + (RouteLenStorage / Speed));		
			}
			if ( (LoadB > Volume * Qty) & (LoadCap - Load < LoadB ) )  {
				Bid = -1;
			}	
			if ( (LoadB <= Volume * Qty) & (LoadCap - Load >= Volume * Qty)) {
				Bid = BidAux2;
			//		Bid = math.round((RouteLenShop / Speed) + (RouteLenStorage / Speed));
			}
			if ( (LoadB <= Volume * Qty) & (LoadCap - Load < Volume * Qty) ) {
				Bid = -1;
			}	
		}
	}
	.
	
+!calculate_route(FacilityId,TaskId,Battery)
	: chargingList(List) & role(_, Speed, LoadCap, BatteryCap, Tools) & closest_facility(List, FacilityId, FacilityId2) & enough_battery(FacilityId, FacilityId2, Result)
<-
	?bid(BidAux,TaskId);
	?chargeExp(Exp,TaskId);
	if (not Result) {
		?lat(Lat);
		?lon(Lon);
		?getFacility(FacilityId,Flat,Flon,Aux1,Aux2);
		+onMyWay([],TaskId);
		?inFacility(Fac);
		if (.member(Fac,List)) {
			.delete(Fac,List,List2);
		}
		else {
			List2 = List;
		}
		for(.member(ChargingId,List2)){
			?chargingStation(ChargingId,Clat,Clon,_,_,_);
			if(math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Lat-Clat)**2+(Lon-Clon)**2)) & math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Clat-Flat)**2+(Clon-Flon)**2))){
				?onMyWay(AuxList,TaskId);
				-onMyWay(AuxList,TaskId);
				+onMyWay([ChargingId|AuxList],TaskId);
				//.print("me-to-facility: ",math.sqrt((Lat-Flat)**2+(Lon-Flon)**2));
				//.print("me-to-charging: ",math.sqrt((Lat-Clat)**2+(Lon-Clon)**2));
				//.print("charging-to-facility: ",math.sqrt((Clat-Flat)**2+(Clon-Flon)**2));
			}
		}
		?onMyWay(Aux2List,TaskId);
		-onMyWay(Aux2List,TaskId);
	//	.print("Lista: ",Aux2List);
		if(.empty(Aux2List)){
			?closest_facility(List2,Facility);
//			FacilityAux2 = Facility;
			!calculate_routeCharging(FacilityId, Facility, TaskId, BatteryCap);
//			-bid(BidAux,TaskId);
//			+bid(-1,TaskId);
//			!calculate_route(FacilityId,TaskId);				
//			.print("There is no charging station between me and my goal, going to the nearest one.");
		}
		else{
	//		.print("FacilityID: ",FacilityId);
			?closest_facility(Aux2List,Facility);
			?enough_battery_charging2(Facility, Result,Battery);
			if (not Result) {
	//			.print("I don't even have battery to go to the nearest charging station of the list, go to the nearest overall!");
				?closest_facility(List2,FacilityAux);
				!calculate_routeCharging(FacilityId, FacilityAux, TaskId, BatteryCap);
//				-+bid(-1,TaskId);
//				FacilityAux2 = FacilityAux;
			}
			else {
				?closest_facility(Aux2List,FacilityId,FacilityAux);
	//			.print("Closest of ",Aux2List," charging station to ",FacilityId," is ",FacilityAux);
				?enough_battery_charging2(FacilityAux, ResultAux,Battery);
				if (ResultAux) {
//					FacilityAux2 = FacilityAux;
					?route(FacilityAux, RouteLen);
					-bid(BidAux,TaskId);
					+bid(BidAux + math.round(RouteLen / Speed),TaskId);
					!calculate_routeCharging(FacilityId, FacilityAux, TaskId, BatteryCap);
				}
				else {
					.delete(FacilityAux,Aux2List,Aux2List2);
					!check_list_charging(Aux2List2,FacilityId);
					?charge_in(FacAux);
					-charge_in(FacAux);
					?route(FacAux, RouteLen);
					-bid(BidAux,TaskId);
					+bid(BidAux + math.round(RouteLen / Speed),TaskId);
					!calculate_routeCharging(FacilityId, FacAux, TaskId, BatteryCap);
//					FacilityAux2 = FacAux;
				}
			}
		}
	}
	else {
		?route(FacilityId, RouteLen);
		-chargeExp(Exp);
		+chargeExp(Exp + math.round(RouteLen / Speed * 10),TaskId);
		-bid(BidAux,TaskId);
		+bid(BidAux + math.round(RouteLen / Speed),TaskId);
//		.print("Bid: ",math.round(RouteLen / Speed));
	}
	.
	
+!calculate_routeCharging(FacilityId,FacilityAtm,TaskId,Battery)
	: chargingList(List) & role(_, Speed, LoadCap, BatteryCap, Tools) & closest_facility(List, FacilityId, FacilityId2) & enough_battery2(FacilityAtm, FacilityId, FacilityId2, Result)
<-
	?bid(BidAux,TaskId);
	?chargeExp(Exp,TaskId);
	if (not Result) {
		?lat(Lat);
		?lon(Lon);
		?getFacility(FacilityId,Flat,Flon,Aux1,Aux2);
		+onMyWay([],TaskId);
		?inFacility(Fac);
		if (.member(Fac,List)) {
			.delete(Fac,List,List2);
		}
		else {
			List2 = List;
		}
		for(.member(ChargingId,List2)){
			?chargingStation(ChargingId,Clat,Clon,_,_,_);
			if(math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Lat-Clat)**2+(Lon-Clon)**2)) & math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Clat-Flat)**2+(Clon-Flon)**2))){
				?onMyWay(AuxList,TaskId);
				-onMyWay(AuxList,TaskId);
				+onMyWay([ChargingId|AuxList],TaskId);
				//.print("me-to-facility: ",math.sqrt((Lat-Flat)**2+(Lon-Flon)**2));
				//.print("me-to-charging: ",math.sqrt((Lat-Clat)**2+(Lon-Clon)**2));
				//.print("charging-to-facility: ",math.sqrt((Clat-Flat)**2+(Clon-Flon)**2));
			}
		}
		?onMyWay(Aux2List,TaskId);
		-onMyWay(Aux2List,TaskId);		
	//	.print("Lista: ",Aux2List);
		if(.empty(Aux2List)){
			?closest_facility(List2,Facility);
//			FacilityAux2 = Facility;
			-bid(BidAux,TaskId);
			+bid(-1,TaskId);
//			!calculate_route(FacilityId,TaskId);				
//			.print("There is no charging station between me and my goal, going to the nearest one.");
		}
		else{
	//		.print("FacilityID: ",FacilityId);
			?closest_facility(Aux2List,Facility);
			?enough_battery_charging2(Facility, Result,Battery);
			if (not Result) {
	//			.print("I don't even have battery to go to the nearest charging station of the list, go to the nearest overall!");
//				?closest_facility(List2,FacilityAux);
				-bid(BidAux,TaskId);
				+bid(-1,TaskId);
//				FacilityAux2 = FacilityAux;
			}
			else {
				?closest_facility(Aux2List,FacilityId,FacilityAux);
	//			.print("Closest of ",Aux2List," charging station to ",FacilityId," is ",FacilityAux);
				?enough_battery_charging2(FacilityAux, ResultAux,Battery);
				if (ResultAux) {
//					FacilityAux2 = FacilityAux;
					?route(FacilityAtm, FacilityAux, RouteLen);
					-bid(BidAux,TaskId);
					+bid(BidAux + math.round(RouteLen / Speed),TaskId);
					!calculate_routeCharging(FacilityId, FacilityAux, TaskId, BatteryCap);
				}
				else {
					.delete(FacilityAux,Aux2List,Aux2List2);
					!check_list_charging(Aux2List2,FacilityId);
					?charge_in(FacAux);
					-charge_in(FacAux);
					?route(FacilityAtm, FacAux, RouteLen);
					-bid(BidAux,TaskId);
					+bid(BidAux + math.round(RouteLen / Speed),TaskId);
					!calculate_routeCharging(FacilityId, FacAux, TaskId, BatteryCap);
//					FacilityAux2 = FacAux;
				}
			}
		}
	}
	else {
		?route(FacilityAtm, FacilityId, RouteLen);
		-chargeExp(Exp);
		+chargeExp(Exp + math.round(RouteLen / Speed * 10),TaskId);
		-bid(BidAux,TaskId);
		+bid(BidAux + math.round(RouteLen / Speed),TaskId);
//		.print("Bid: ",math.round(RouteLen / Speed));
	}
	.
	
+!calculate_routeStorage(FacilityId,FacilityAtm,TaskId,Battery)
	: chargingList(List) & role(_, Speed, LoadCap, BatteryCap, Tools) & closest_facility(List, FacilityId, FacilityId2) & enough_battery2(FacilityAtm, FacilityId, FacilityId2, Result)
<-
	?bid(BidAux,TaskId);
//	?chargeExp(Exp,TaskId);
	if (not Result) {
		?lat(Lat);
		?lon(Lon);
		?getFacility(FacilityId,Flat,Flon,Aux1,Aux2);
		+onMyWay([],TaskId);
		?inFacility(Fac);
		if (.member(Fac,List)) {
			.delete(Fac,List,List2);
		}
		else {
			List2 = List;
		}
		for(.member(ChargingId,List2)){
			?chargingStation(ChargingId,Clat,Clon,_,_,_);
			if(math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Lat-Clat)**2+(Lon-Clon)**2)) & math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Clat-Flat)**2+(Clon-Flon)**2))){
				?onMyWay(AuxList,TaskId);
				-onMyWay(AuxList,TaskId);
				+onMyWay([ChargingId|AuxList],TaskId);
				//.print("me-to-facility: ",math.sqrt((Lat-Flat)**2+(Lon-Flon)**2));
				//.print("me-to-charging: ",math.sqrt((Lat-Clat)**2+(Lon-Clon)**2));
				//.print("charging-to-facility: ",math.sqrt((Clat-Flat)**2+(Clon-Flon)**2));
			}
		}
		?onMyWay(Aux2List,TaskId);
		-onMyWay(Aux2List,TaskId);		
	//	.print("Lista: ",Aux2List);
		if(.empty(Aux2List)){
			?closest_facility(List2,Facility);
//			FacilityAux2 = Facility;
			!calculate_routeCharging(FacilityId, Facility, TaskId, BatteryCap);
//			!calculate_route(FacilityId,TaskId);				
//			.print("There is no charging station between me and my goal, going to the nearest one.");
		}
		else{
	//		.print("FacilityID: ",FacilityId);
			?closest_facility(Aux2List,Facility);
			?enough_battery_charging2(Facility, Result,Battery);
			if (not Result) {
	//			.print("I don't even have battery to go to the nearest charging station of the list, go to the nearest overall!");
				?closest_facility(List2,FacilityAux);
				!calculate_routeCharging(FacilityId, FacilityAux, TaskId, BatteryCap);
//				-+bid(-1,TaskId);
//				FacilityAux2 = FacilityAux;
			}
			else {
				?closest_facility(Aux2List,FacilityId,FacilityAux);
	//			.print("Closest of ",Aux2List," charging station to ",FacilityId," is ",FacilityAux);
				?enough_battery_charging2(FacilityAux, ResultAux,Battery);
				if (ResultAux) {
//					FacilityAux2 = FacilityAux;
					?route(FacilityAtm, FacilityAux, RouteLen);
					-bid(BidAux,TaskId);
					+bid(BidAux + math.round(RouteLen / Speed),TaskId);
					!calculate_routeCharging(FacilityId, FacilityAux, TaskId, BatteryCap);
				}
				else {
					.delete(FacilityAux,Aux2List,Aux2List2);
					!check_list_charging(Aux2List2,FacilityId);
					?charge_in(FacAux);
					-charge_in(FacAux);
					?route(FacilityAtm, FacAux, RouteLen);
					-bid(BidAux,TaskId);
					+bid(BidAux + math.round(RouteLen / Speed),TaskId);
					!calculate_routeCharging(FacilityId, FacAux, TaskId, BatteryCap);
//					FacilityAux2 = FacAux;
				}
			}
		}
	}
	else {
		?route(FacilityAtm, FacilityId, RouteLen);
//		-+chargeExp(Exp + math.round(RouteLen / Speed * 10),TaskId);
		-bid(BidAux,TaskId);
		+bid(BidAux + math.round(RouteLen / Speed),TaskId);
//		.print("Bid: ",math.round(RouteLen / Speed));
	}
	.	
	

/* 
@task[atomic]
+task(Task,CNPBoard) 
	: roled(Role, Speed, LoadCap, BatteryCap, Tools)
<- 
	.print("Found a task: ",Task);
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
	!make_bid(Task,BoardId,CNPBoard);
	. 
 
@winner[atomic]
+winner(BidId,Task,Items,JobId,StorageId) 
	: my_bid(BidId,Task)
<- 
	.print("Awarded!.");
	+noBids;
	!decomp([Items]);
	+working(JobId,[Items],StorageId);
	.
@winner2[atomic]	
+winner(BidId,Task,item(ItemId,Qty),JobId,StorageId) 
	: my_bid(X,Y) & not my_bid(BidId,Task) & product(ItemId, Volume, BaseList) & loadExpected(LoadE)
<- 
	.print("Not awarded.");
	-+loadExpected(LoadE - Volume * Qty);
	.
	
+!make_bid(Task,BoardId,CNPBoard)
	: not noBids
<- 
	!create_bid(Task,Bid);
	bid(Bid,BidId)[artifact_id(BoardId)];
	+my_bid(BidId,CNPBoard);
	.print("Bid submitted: ",Bid," - id: ",BidId, " for task: ",CNPBoard);
	.
-!make_bid(Task,BoardId,CNPBoard)
	: noBids
<- 
	.print("No more bids for me.");
	.
-!make_bid(Task,BoardId,CNPBoard)
<- 
	.print("Too late for submitting the bid.");
	.drop_all_intentions;
	.
	
@create_bid[atomic]	
+!create_bid(item(ItemId,Qty),Bid)
	: product(ItemId, Volume, BaseList) & loadExpected(LoadE) & load(Load) & loadTotal(LoadCap) & workshopList([WorkshopId|_]) & shopsList([shop(ShopId,_)|_]) & storageList([StorageId|_]) & roled(_, Speed, _, _, _)
<- 
	?closest_facility([WorkshopId], FacilityA, RouteLenWorkshop);
	?closest_facility([ShopId], FacilityB, RouteLenShop);
	?closest_facility([StorageId], FacilityC, RouteLenStorage);	
	?calculate_bases_load(BaseList,Qty,0,LoadB);
	
	?verify_tools([ItemId],[],ToolsMissing);
	if (ToolsMissing \== [])
	{
		.length(ToolsMissing,L);
		ToolFactor = 2 ** L;
	}
	else {
		ToolFactor = 1;
	}
	
	if ( (LoadB > Volume * Qty) & (LoadCap - Load >= LoadB + LoadE) )
	{
		-+loadExpected(LoadB + LoadE);
		Bid = math.round((RouteLenWorkshop / Speed) + (RouteLenShop / Speed) + (RouteLenStorage / Speed) * ToolFactor);		
	}
	if ( (LoadB > Volume * Qty) & (LoadCap - Load < LoadB + LoadE) ) 
	{
		Bid = 0;
	}	
	if ( (LoadB <= Volume * Qty) & (LoadCap - Load >= Volume * Qty + LoadE) )
	{
		-+loadExpected(Volume * Qty + LoadE);
		Bid = math.round((RouteLenWorkshop / Speed) + (RouteLenShop / Speed) + (RouteLenStorage / Speed) * ToolFactor);
	}
	if ( (LoadB <= Volume * Qty) & (LoadCap - Load < Volume * Qty + LoadE) )
	{
		Bid = 0;
	}
	.	 
*/