/* 
+product(ProductId, Volume, BaseList)[artifact_id(_)]
	: not product(ProductId, Volume, BaseList)
<-
	+product(ProductId, Volume, BaseList);
	+item(ProductId,0);
	.	
	
+charge(Battery)[artifact_id(_)] <- -+charge(Battery).	

+load(Load)[artifact_id(_)] <- -+load(Load).	

+inFacility(Facility)[artifact_id(_)]
	: helpAssemble(ItemId,Qty,Tool,FacilityHelp,Agent)[source(X)] &  FacilityHelp == Facility & warnAgent
<- 
	if (Facility \== none)
	{
		-going(Facility);	
	}
	-+inFacility(Facility);
	-warnAgent;
	.send(X,tell,iAmHere(ItemId,Qty,Tool,FacilityHelp,Agent));
	.
*/