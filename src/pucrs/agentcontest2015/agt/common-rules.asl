//lowBattery :- charge(Battery) & chargeTotal(BatteryCap) & Battery < BatteryCap*60/100.
lowBattery :- charge(Battery) & roled(_, Speed, _, _, _) & chargingList(List) & closestFacility(List, Facility, RouteLen)
              & (RouteLen / Speed * 10 > Battery - 20) .
              // Battery to the closest station > Battery w/ margin => Time to recharge
              // It waste 10 of battery per motion
              // TODO keep watching if 10 will remain the same for all roles

closestFacility(List, Facility) :- roled(Role, _, _, _, _) & pucrs.agentcontest2015.actions.closest(Role, List, Facility).
closestFacility(List, Facility, RouteLen) :- roled(Role, _, _, _, _) & pucrs.agentcontest2015.actions.closest(Role, List, Facility, RouteLen).

bestShop(Shops,Shop) :- .nth(0,Shops,Shop).

verifyItems([item(ItemId,Qty)|List]) :- item(ItemId,Qty) & verifyItems(List).
verifyItems([consumed(ItemId,Qty)|List]) :- item(ItemId,Qty2) & Qty2 >= Qty & verifyItems(List).
verifyItems([tools(ItemId,Qty)|List]) :- item(ItemId,Qty) & verifyItems(List).

verifyTools([],Aux,Result) :- Result = Aux.
verifyTools([ItemId|List],Aux,Result) :- product(ItemId, Volume, BaseList) & getMissingTools(BaseList,[],ListTools,ItemId) & .concat(ListTools,Aux,ResultAux) & verifyTools(List,ResultAux,Result).

getMissingTools([],Aux,ListTools,ItemId) :- ListTools = Aux.
getMissingTools([tools(ToolId,Qty)|List],Aux,ListTools,ItemId) :- item(ToolId,0) & .concat([assemble(ItemId,ToolId)],Aux,ResultAux) & getMissingTools(List,ResultAux,ListTools,ItemId).
getMissingTools([tools(ToolId,Qty)|List],Aux,ListTools,ItemId) :- item(ToolId,1) & getMissingTools(List,Aux,ListTools,ItemId).
getMissingTools([consumed(ItemId2,Qty)|List],Aux,ListTools,ItemId) :- getMissingTools(List,Aux,ListTools,ItemId).

findShops(ItemId,[],Aux,Result) :- Result = Aux.
findShops(ItemId,[shop(ShopId,ListItems)|List],Aux,Result) :- .member(item(ItemId,_,_,_),ListItems) & .concat([ShopId],Aux,ResultAux) & findShops(ItemId,List,ResultAux,Result).
findShops(ItemId,[shop(ShopId,ListItems)|List],Aux,Result) :- not .member(item(ItemId,_,_,_),ListItems) & findShops(ItemId,List,Aux,Result).

count(ItemId,[],Aux,Qty) :- Qty = Aux.
count(ItemId,[ItemId|ListAssemble],Aux,Qty) :- Aux2 = Aux+1 & count(ItemId,ListAssemble,Aux2,Qty).
count(ItemId,[ItemId2|ListAssemble],Aux,Qty) :- count(ItemId,ListAssemble,Aux,Qty).

isTool(ItemId) :- ItemId == tool1 | ItemId == tool2 | ItemId == tool3 | ItemId == tool4.