+product(ProductId, Volume, BaseList)[artifact_id(_)]
	: not product(ProductId, Volume, BaseList)
<-
	+product(ProductId, Volume, BaseList);
	+item(ProductId,0);
	.	
	
+charge(Battery)[artifact_id(_)] <- -+charge(Battery).	

+inFacility(Facility)[artifact_id(_)]
	: going(GoingFacility) & Facility == GoingFacility 
<- 
	if (going(GoingFacility) & Facility == GoingFacility) {
		-going(GoingFacility);
	};
	-+inFacility(Facility);
	.