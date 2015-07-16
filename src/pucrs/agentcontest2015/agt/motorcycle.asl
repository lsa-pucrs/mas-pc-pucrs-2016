chargingList([]).
chargeTotal(3500).

lowBattery :- charge(X) & X < 4000.

closestFacility(L,F) :- .nth(0,L,F).

!register.

+charge(X)
	: charging & chargeTotal(C) & C == X
<-
	.print("Stop charging, battery is full.");
	-charging;
	.
	
+inFacility(X)[artifact_id(_)]
	: going(L) & X == L 
<- 
	if (going(L) & X == L) {
		-going(L);
	};
	-+inFacility(X);
	.
	
@chargingList[atomic]
+chargingStation(X,X2,X3,X4,X5,X6) 
	:  chargingList(L) & not .member(X,L) 
<- 
	-+chargingList([X|L]);
	.

+!select_goal 
	: lowBattery & inFacility(X) & chargingList(L) & .member(X,L) & not charging  
<- 
	.print("Began charging.");
	!charge;
	. 

+!select_goal 
	: charging 
<- 
	.print("Keep charging."); 
	!continue;
	.
	
+!select_goal 
	: not going(_) & lowBattery & chargingList(L) & closestFacility(L,F) 
<- 
	.print("Going to charging station ",F); 
	!goto(F);
	.

+!select_goal 
	: going(L) 
<-
	.print("Continuing to location ",L); 
	!continue;
	.

+!select_goal 
	: true
<-
	.print("Nothing to do at this step");
	!skip;
	.	