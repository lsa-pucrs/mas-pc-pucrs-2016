/* 
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