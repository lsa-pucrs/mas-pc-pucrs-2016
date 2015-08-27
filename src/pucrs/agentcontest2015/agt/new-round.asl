+!new_round(Role, Speed, LoadCap, BatteryCap, Tools)
	: true
<-
	+chargingList([]);
	+shopsList([]);
	+workshopList([]);
	+assembleList([]);
	+verifyItems([]);
	+auxList([]);                    // lista para limpar as bases compostas
	+tools(Tools);
	+chargeTotal(BatteryCap);
	+loadTotal(LoadCap);	
	.
