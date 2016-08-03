package pucrs.agentcontest2016.actions;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import massim.competition2015.scenario.Route;
import pucrs.agentcontest2016.env.MapHelper;

public class route extends DefaultInternalAction {

	private static final long serialVersionUID = 3044142657303654485L;

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		String to = "";
		String from = "";
		if (args.length == 3){
			from = ts.getUserAgArch().getAgName();
			to = args[1].toString();
		} else if(args.length == 4){
			from = args[1].toString();
			to = args[2].toString();
		}
		String role = args[0].toString();
		String type = "road";
		if(role.equals("drone")){
			type = "air";
		}
		Route route = MapHelper.getNewRoute(from, to, type);
		boolean ret = true;
		if (args.length == 3){
			ret = ret & un.unifies(args[2], new NumberTermImpl(route.getRouteLength()));
		} else if (args.length == 4){
			ret = ret & un.unifies(args[3], new NumberTermImpl(route.getRouteLength()));
		}
		return ret;
	}
}