lowBattery :- charge(Battery) & chargeTotal(BatteryCap) & Battery < BatteryCap*60/100.

closestFacility(List,Facility) :- .nth(0,List,Facility).

bestShop(Shops,Shop) :- .nth(0,Shops,Shop).

verifyItems([item(ItemId,Qty)|List]) :- item(ItemId,Qty) & verifyItems(List).
verifyItems([consumed(ItemId,Qty)|List]) :- item(ItemId,Qty2) & Qty2 >= Qty & verifyItems(List).
verifyItems([tools(ItemId,Qty)|List]) :- item(ItemId,Qty) & verifyItems(List).

findShops(ItemId,[],Aux,Result) :- Result = Aux.
findShops(ItemId,[shop(ShopId,ListItems)|List],Aux,Result) :- .member(item(ItemId,_,_,_),ListItems) & .concat([ShopId],Aux,ResultAux) & findShops(ItemId,List,ResultAux,Result).
findShops(ItemId,[shop(ShopId,ListItems)|List],Aux,Result) :- not .member(item(ItemId,_,_,_),ListItems) & findShops(ItemId,List,Aux,Result).