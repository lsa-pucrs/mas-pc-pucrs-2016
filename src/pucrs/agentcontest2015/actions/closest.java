package pucrs.agentcontest2015.actions;

import jason.JasonException;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.StringTerm;
import jason.asSyntax.Term;
import massim.competition2015.scenario.Route;
import pucrs.agentcontest2015.env.MapHelper;

public class closest extends DefaultInternalAction {

	private static final long serialVersionUID = 3044142657303654485L;

	@Override
	public int getMinArgs() {
		return 3;
	}

	@Override
	public int getMaxArgs() {
		return 4;
	}

	@Override
	protected void checkArguments(Term[] args) throws JasonException {
		super.checkArguments(args);
		if (!args[0].isString())
			throw JasonException.createWrongArgument(this, "");
		if (!args[1].isList())
			throw JasonException.createWrongArgument(this, "");
		if (!args[2].isVar())
			throw JasonException.createWrongArgument(this, "");
		if (args.length == 4 && !args[3].isVar())
			throw JasonException.createWrongArgument(this, "");
	}

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		checkArguments(args);
		String role = ((StringTerm) args[0]).getString();
		String type = "road";
		if(role.equals("drone")){
			type = "air";
		}
		ListTerm ids = (ListTerm) args[1];
		String closest = null;
		double len = Integer.MAX_VALUE;
		String from = ts.getUserAgArch().getAgName();
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
			if (args.length == 4){
				ret = ret & un.unifies(args[3], new NumberTermImpl(len));
			}
		}
		return ret;
	}
}
