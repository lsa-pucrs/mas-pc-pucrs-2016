//!start.
//
//+!start
//	: true
//<-
// 	.wait({ +step(_) });
// 	
// 	!waitShopList;
// 	!calculateStepsRequiredAllShops;
// 	
// 	+free;
//    .

/* 
+!start
	: true
<-
 	.wait({ +step(_) });
	//!find_tools;
	//!get_tools;
	+free;
	.

+step(Step)
	: Step mod 30 == 0
<-
	!suspend;
	!post_auction;
	!resume;
	.
*/