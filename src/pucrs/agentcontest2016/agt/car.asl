!start.

+!start
	: true
<-
 	.wait({ +step(_) });
 	!go;
    .
 
+!go
	: true
<-
    !goto(shop1);
    !goto(shop2);
    !go;
.

+charge(C) : C < 100 & not .desire(to_charge) <- !to_charge.
+!to_charge
<- .print("going to charge my battery!");
.suspend(go);
?chargingStation(F,_,_,_,_,_);
!goto(F);
!charge;
.resume(go); 
. 

/* 
+!start
	: true
<-
 	.wait({ +step(_) });
	!find_tools;
	!get_tools;
	+free;
	.
*/