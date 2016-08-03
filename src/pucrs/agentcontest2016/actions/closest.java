package pucrs.agentcontest2016.actions;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import massim.competition2015.scenario.Route;
import pucrs.agentcontest2016.env.MapHelper;

public class closest extends DefaultInternalAction {

	private static final long serialVersionUID = 3044142657303654485L;

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		String role = args[0].toString();
		String type = "road";
		if(role.equals("drone")){
			type = "air";
		}
		ListTerm ids = (ListTerm) args[1];
		String closest = null;
		double len = Integer.MAX_VALUE;
		String from = null;		
		if (args.length == 4){
			from = args[3].toString();
		}
		else {
			from = ts.getUserAgArch().getAgName();
		}
		for (Term term : ids) {
			String to = term.toString();
			Route route = MapHelper.getNewRoute(from, to, type);
			if(route.getRouteLength() < len){
				closest = to;
				len = route.getRouteLength();
			}
		}
		boolean ret = true;
		if(closest != null){
			ret = un.unifies(args[2], Literal.parseLiteral(closest)); 
		}
		return ret;
	}
}
