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
	: buyList(_,_,ShopId) & .my_name(Me) & role(_, _, LoadCap, _, _)
<-
	!goto(ShopId);
	for ( buyList(Item2,Qty2,ShopId) ) { 
		while ( buyList(Item,Qty,ShopId) ) {
			!buy(Item,Qty);
			.wait(1500);
			?verify_item(Item,Qty,Result);
			if (Result) {
//				.print("REMOVENDO ITEM");
				-buyList(Item,Qty,ShopId);
			}
//			else {
//				for (item(X,Y)) {
//					.print("Item #",Y," ",X);
//				}
//			}
		}
	}
	!goto(StorageId);
	!deliver_job(JobId);
	.send(vehicle1,tell,done);
	updateLoad(Me,LoadCap);
	?winner(List,JobId,StorageId,ShopId)[source(X)];
	-winner(List,JobId,StorageId,ShopId)[source(X)];
	!free;
	.
	
+!go_charge(FacilityId)
	:  chargingList(List) & lat(Lat) & lon(Lon) & getFacility(FacilityId,Flat,Flon,Aux1,Aux2)
<-
	+onMyWay([]);
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
			?onMyWay(AuxList);
			-onMyWay(AuxList);
			+onMyWay([ChargingId|AuxList]);
			//.print("me-to-facility: ",math.sqrt((Lat-Flat)**2+(Lon-Flon)**2));
			//.print("me-to-charging: ",math.sqrt((Lat-Clat)**2+(Lon-Clon)**2));
			//.print("charging-to-facility: ",math.sqrt((Clat-Flat)**2+(Clon-Flon)**2));
		}
	}
	?onMyWay(Aux2List);
//	.print("Lista: ",Aux2List);
	if(.empty(Aux2List)){
		?closest_facility(List2,Facility);
		FacilityAux2 = Facility;
	}
	else{
//		.print("FacilityID: ",FacilityId);
		?closest_facility(Aux2List,Facility);
		?enough_battery_charging(Facility, Result);
		if (not Result) {
			?closest_facility(List2,FacilityAux);
//			.print("!!!!!!!!!!!!! not enough battery to get to ",Facility," going instead to ",FacilityAux);
			FacilityAux2 = FacilityAux;
		}
		else {
			FacilityAux2 = Facility;
		}
	}
	-onMyWay(Aux2List);
	.print("**** Going to charge my battery at ", FacilityAux2);
	!goto(FacilityAux2);
	!charge;
	.
	
//### RINGING ###
+!ringingFinished
	: not .desire(goto(_))
<-
	-myProposal(_);
	!free;
	.
+!ringingFinished
<-
	-myProposal(_);
	.
	
+!go_to_facility(Facility)
<-
	!goto(Facility);
	?step(S);
	.print("I have arrived at ", Facility, "   -   Step: ",S);
	.send(vehicle1,tell,done);
	!free;
	.
+!start_ringing
	: .my_name(Me) & shopList(List) & find_shops_id(List,[],ListOfShops)
<-
//	.print("Starting Ringing");
	+numberAwarded(.length(List));

	!order_agents_to_go_to_the_shops(ListOfAgents);

	.delete(agents(Me),ListOfAgents,ListOfAgentsWithoutMe);
	
	!create_list_of_proposals(ListOfShops,ListOfProposals);
	
	!make_proposal(ListOfShops,ListOfProposals,ListOfAgentsWithoutMe,ListOfAgents);
	. 
+!create_list_of_proposals(ListOfShops, ListOfProposals)
<-
	+tempProposalsShopRing([]);	
	for (.member(Shop, ListOfShops)){
		?tempProposalsShopRing(InitialList);
		.concat(InitialList,[currentProposal(Shop,"ini1",100,"ini2",100)],NewList);	
		-+tempProposalsShopRing(NewList);
	}
	
	?tempProposalsShopRing(FinalList);	
	ListOfProposals = FinalList;
	-tempProposalsShopRing(FinalList);
	.

+!calculate_steps_required_all_shops
	: .my_name(Me) & role(Role, Speed, _, _, _) & shopList(List) & find_shops_id(List,[],ShopsList)
<- 	
	pucrs.agentcontest2016.actions.pathsToFacilities(Me, Role, Speed, ShopsList, Proposal);
	
	-+myProposal(Proposal);
	.
+!calculate_steps_required_all_shops
<- 	
// 	Adicionado este plano pq no de cima de vez em quando a lista de shops n�o era preenchida e ferrava tudo
	!calculate_steps_required_all_shops;
	.
+!sendAgentsToTheirShops
	: tempAgentsSendProposals(ListShopAgent)
<-
	for (.member(proposalAgent(Shop,Agent,_),ListShopAgent) ){
		.send(Agent,achieve,go_to_facility(Shop));
	}
	.
//+!calculateBestShopToEachAgent
//	: tempComparingProposals(Proposals)
//<-
////	.print("Checking the nearest agent for each shop");
//	-+tempAgentsSendProposals([]); 
//	
//	for (.member(currentProposal(Shop,FirstAgent,FirstSteps,SecondAgent,SecondSteps),Proposals) ){		
//		Difference = (SecondSteps - FirstSteps);
//		
//		?tempAgentsSendProposals(InitialList);
//		
//		if (.member(proposalAgent(ShopProposal,FirstAgent,DifferenceStepsTwoAgents), InitialList) ){	
//			if (Difference > DifferenceStepsTwoAgents){
//				.difference(InitialList,[proposalAgent(ShopProposal,FirstAgent,DifferenceStepsTwoAgents)],TempProposal);
//				.concat(TempProposal,[proposalAgent(Shop,FirstAgent,Difference)],NewProposals);	
//				-+tempAgentsSendProposals(NewProposals);
//			} 
//		} else{
//			.concat(InitialList,[proposalAgent(Shop,FirstAgent,Difference)],NewProposals);	
//			-+tempAgentsSendProposals(NewProposals);
//		}	
//	}	
// 	.
+!calculateBestShopToEachAgent
	: tempComparingProposals(Proposals)
<-
//	.print("Checking the nearest agent for each shop");
	-+tempAgentsSendProposals([]); 
	
	for (.member(currentProposal(Shop,FirstAgent,FirstSteps,SecondAgent,SecondSteps),Proposals) ){		
		
		?tempAgentsSendProposals(InitialList);
		
		if (.member(proposalAgent(ShopProposal,FirstAgent,WorstBetterSteps), InitialList) ){	
			if (FirstSteps > WorstBetterSteps){
				.difference(InitialList,[proposalAgent(ShopProposal,FirstAgent,WorstBetterSteps)],TempProposal);
				.concat(TempProposal,[proposalAgent(Shop,FirstAgent,FirstSteps)],NewProposals);	
				-+tempAgentsSendProposals(NewProposals);
			} 
		} else{
			.concat(InitialList,[proposalAgent(Shop,FirstAgent,FirstSteps)],NewProposals);	
			-+tempAgentsSendProposals(NewProposals);
		}	
	}	
 	.
+!make_proposal(AvailableShops, Proposals, [], AvailableAgents)
	: .my_name(Me)
<-
//	.print("I'm the last one to make a proposal");
	!calculate_steps_required_all_shops;
		
	!compare_proposals(AvailableShops, Proposals);
	
	!calculateBestShopToEachAgent;
	
	!sendAgentsToTheirShops;
	
	!find_out_the_remaing_agent_and_shops(AvailableShops, AvailableAgents);
	
	?tempNewListAvailableShops(NewAvailableShops);
	!create_list_of_proposals(NewAvailableShops, ListOfProposals);	
	
	?tempNextAgent(NextAgent);	
	?tempListAgentsRing(ListAgents);
	?tempNewListAvailableAgent(NewAvailableAgents);
	
	if (not .empty(NewAvailableShops)){
		.send(NextAgent,achieve,make_proposal(NewAvailableShops,ListOfProposals,ListAgents,NewAvailableAgents));
	} else{
		.print("Ringing is Done");
		.broadcast(achieve,ringingFinished);
		!!free;	
	}	
	
	-tempComparingProposals(_);	
	-tempAgentsSendProposals(_);
	-tempNewListAvailableAgent(_);
	-tempNewListAvailableShops(_);
	-tempNextAgent(_);
	-tempListAgentsRing(_);
	.
+!make_proposal(AvailableShops, Proposals, [agents(NextAgent)|RemainingAgents], AvailableAgents)
	: .my_name(Me)
<-
	!calculate_steps_required_all_shops;

	!compare_proposals(AvailableShops, Proposals);
	
	!send_proposal_next_agent(AvailableShops, NextAgent, RemainingAgents, AvailableAgents);
	
	-tempComparingProposals(_);	
	.
+!compare_proposals(AvailableShops, Proposals)
	: .my_name(Me) & myProposal(MyProposal)
<-
	-+tempComparingProposals([]);	
	
	for (.member(proposal(_,Shop,MeSteps), MyProposal)){	
		ShopBusca = Shop;
		if (.member(currentProposal(Shop,FirstAgent,FirstSteps,SecondAgent,SecondSteps),Proposals) ){		
			if (MeSteps < FirstSteps){
				RetSecondAgent 	= FirstAgent;
				RetSecondSteps 	= FirstSteps;
				RetFirstAgent 	= Me;
				RetFirstSteps 	= MeSteps;
			} else{
				if (MeSteps < SecondSteps){
					RetSecondAgent 	= Me;
					RetSecondSteps 	= MeSteps;
					RetFirstAgent 	= FirstAgent;
					RetFirstSteps 	= FirstSteps;
				} else{
					RetSecondAgent 	= SecondAgent;
					RetSecondSteps 	= SecondSteps;
					RetFirstAgent 	= FirstAgent;
					RetFirstSteps 	= FirstSteps;
				}
			}
			
			?tempComparingProposals(InitialList);
			.concat(InitialList,[currentProposal(Shop,RetFirstAgent,RetFirstSteps,RetSecondAgent,RetSecondSteps)],NewProposals);
			-+tempComparingProposals(NewProposals);
		} 
	}
	
	?tempComparingProposals(LastProposals);
	.
+!compare_proposals(AvailableShops, Proposals)
<-
	.print("Passou Aqui, Nao Deveria");
	?myProposal(MyProposal);	
	.
+!find_out_the_remaing_agent_and_shops(AvailableShops, AvailableAgents)
	: tempAgentsSendProposals(ListShopAgent)
<-
	+tempNewListAvailableAgent(AvailableAgents);
	+tempNewListAvailableShops(AvailableShops);
	
	for(.member(proposalAgent(Shop,Agent,_),ListShopAgent)){		
		?tempNewListAvailableAgent(A);		
		.delete(agents(Agent),A,NewA);	
		-+tempNewListAvailableAgent(NewA);			
		
		?tempNewListAvailableShops(S);
		.delete(Shop,S,NewS);
		-+tempNewListAvailableShops(NewS);		
	}
	
	?tempNewListAvailableAgent([agents(Next)|Tail]);
	-+tempNextAgent(Next);
	-+tempListAgentsRing(Tail);
	.
+!send_proposal_next_agent(AvailableShops, NextAgent, RemainingAgents, AvailableAgents)
	: tempComparingProposals(Proposals)
<-
	.send(NextAgent,achieve,make_proposal(AvailableShops, Proposals, RemainingAgents, AvailableAgents));
	.
+!order_agents_to_go_to_the_shops(ListOfAgents)
	: not initiatorShopChoice
<-	
//	.findall(agents(Name),play(Name,truck,_),ListTrucks);
//	.findall(agents(Name),play(Name,car,_),ListCars);
//	.findall(agents(Name),play(Name,motorcycle,_),ListMotorcycles);
//	.findall(agents(Name),play(Name,drone,_),ListDrones);
	
	ListOfAgents = [agents(vehicle1),agents(vehicle2),agents(vehicle3),agents(vehicle4),agents(vehicle5),agents(vehicle6),agents(vehicle7),agents(vehicle8),agents(vehicle9),agents(vehicle10),agents(vehicle11),agents(vehicle12),agents(vehicle13),agents(vehicle14),agents(vehicle15),agents(vehicle16)];

	//.concat(ListDrones,ListMotorcycles,ListCars,ListTrucks,ListOfAgents);
	//.print("AGENTS ",ListOfAgents);
	.	
//### RINGING ###

// We need to experiment tweaking the wait value
+!free
	: not going(_) | not charging
<-
	!skip;
	.wait(500);
	!free;
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