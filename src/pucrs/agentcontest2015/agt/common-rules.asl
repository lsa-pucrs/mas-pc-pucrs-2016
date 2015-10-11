best_shop([Shop|_],Shop).

find_shops(ItemId,[],[]).
find_shops(ItemId,[shop(ShopId,ListItems)|List],[ShopId|Result]) :- .member(item(ItemId,_,_,_),ListItems) & find_shops(ItemId,List,Result).
find_shops(ItemId,[shop(ShopId,ListItems)|List],Result) :- not .member(item(ItemId,_,_,_),ListItems) & find_shops(ItemId,List,Result).

closest_facility(List, Facility) :- role(Role, _, _, _, _) & pucrs.agentcontest2015.actions.closest(Role, List, Facility).
closest_facility(List, Facility, RouteLen) :- role(Role, _, _, _, _) & pucrs.agentcontest2015.actions.closest(Role, List, Facility, RouteLen).

/* 
//low_battery :- charge(Battery) & chargeTotal(BatteryCap) & Battery < BatteryCap*60/100.
low_battery :- not goHorse & charge(Battery) & roled(_, Speed, _, _, _) & chargingList(List) & closest_facility(List, Facility, RouteLen)
              & (RouteLen / Speed * 10 > Battery - 20) .
              // Battery to the closest station > Battery w/ margin => Time to recharge
              // It waste 10 of battery per motion
              // TODO keep watching if 10 will remain the same for all roles


closest_facility_drone(List, Facility, RouteLen) :- Role = "drone" & pucrs.agentcontest2015.actions.closest(Role, List, Facility, RouteLen).

verify_items([item(ItemId,Qty)|List]) :- item(ItemId,Qty2) & Qty2 >= Qty & verify_items(List).
verify_items([consumed(ItemId,Qty)|List]) :- item(ItemId,Qty2) & Qty2 >= Qty & verify_items(List).
verify_items([tools(ItemId,Qty)|List]) :- item(ItemId,Qty) & verify_items(List).

verify_tools([],Aux,Result) :- Result = Aux.
verify_tools([ItemId|List],Aux,Result) :- product(ItemId, Volume, BaseList) & get_missing_tools(BaseList,[],ListTools,ItemId) & .concat(ListTools,Aux,ResultAux) & verify_tools(List,ResultAux,Result).

get_missing_tools([],Aux,ListTools,ItemId) :- ListTools = Aux.
get_missing_tools([tools(ToolId,Qty)|List],Aux,ListTools,ItemId) :- item(ToolId,0) & .concat([assemble(ItemId,ToolId)],Aux,ResultAux) & get_missing_tools(List,ResultAux,ListTools,ItemId).
get_missing_tools([tools(ToolId,Qty)|List],Aux,ListTools,ItemId) :- item(ToolId,1) & get_missing_tools(List,Aux,ListTools,ItemId).
get_missing_tools([consumed(ItemId2,Qty)|List],Aux,ListTools,ItemId) :- get_missing_tools(List,Aux,ListTools,ItemId).

count(ItemId,[],Aux,Qty) :- Qty = Aux.
count(ItemId,[ItemId|ListAssemble],Aux,Qty) :- Aux2 = Aux+1 & count(ItemId,ListAssemble,Aux2,Qty).
count(ItemId,[ItemId2|ListAssemble],Aux,Qty) :- count(ItemId,ListAssemble,Aux,Qty).

select_bid([],bid(AuxBid,AuxBidId),bid(BidWinner,BidIdWinner)) :- BidWinner = AuxBid & BidIdWinner = AuxBidId.
select_bid([bid(Bid,BidId)|Bids],bid(AuxBid,AuxBidId),BidWinner) :- Bid \== 0 & Bid < AuxBid & select_bid(Bids,bid(Bid,BidId),BidWinner).
select_bid([bid(Bid,BidId)|Bids],bid(AuxBid,AuxBidId),BidWinner) :- select_bid(Bids,bid(AuxBid,AuxBidId),BidWinner).

calculate_bases_load([],Qty,Aux,LoadB) :- LoadB = Qty * Aux.
calculate_bases_load([consumed(ItemId,Qty2)|BaseList],Qty,Aux,LoadB) :- product(ItemId,Volume,BaseList2) & BaseList2 == [] & calculate_bases_load(BaseList,Qty,Volume * Qty2 + Aux,LoadB).
calculate_bases_load([consumed(ItemId,Qty2)|BaseList],Qty,Aux,LoadB) :- product(ItemId,Volume,BaseList2) & BaseList2 \== [] & calculate_bases_load(BaseList2,Qty,Aux,LoadB2) & calculate_bases_load(BaseList,Qty,LoadB2,LoadB).
calculate_bases_load([tools(ToolId,Qty2)|BaseList],Qty,Aux,LoadB) :- calculate_bases_load(BaseList,Qty,Aux,LoadB).

is_tool(ItemId) :- ItemId == tool1 | ItemId == tool2 | ItemId == tool3 | ItemId == tool4.

items_has_price([item(NItem,Price,Qty,Load)]):- Price\==0.
items_has_price([item(NItem,Price,Qty,Load)|L]):- Price\==0.
*/