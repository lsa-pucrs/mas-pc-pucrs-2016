+product(ProductId, Volume, BaseList)[artifact_id(_)]
	: not product(ProductId, Volume, BaseList)
<-
	+product(ProductId, Volume, BaseList);
	+item(ProductId,0);
	.	
	
+charge(Battery)[artifact_id(_)] <- -+charge(Battery).	

+inFacility(Facility)[artifact_id(_)]
	: helpAssemble(ItemId,Qty,Tool,FacilityHelp,Agent)[source(X)] &  FacilityHelp == Facility & warnAgent
<- 
	if (going(GoingFacility) & Facility == GoingFacility) {
		-going(GoingFacility);
	};
	-+inFacility(Facility);
	-warnAgent;
	.send(X,tell,iAmHere);
	.

+inFacility(Facility)[artifact_id(_)]
	: true
<- 
	if (going(GoingFacility) & Facility == GoingFacility) {
		-going(GoingFacility);
	};
	-+inFacility(Facility);
	.