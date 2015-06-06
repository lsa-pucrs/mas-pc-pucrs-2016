package pucrs.agentcontest2015.env;

import jason.JasonException;
import jason.asSemantics.Agent;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Pred;
import jason.asSyntax.Term;
import jason.asSyntax.directives.DirectiveProcessor;
import jason.asSyntax.directives.Include;

import java.util.Arrays;

public class include extends DefaultInternalAction {

	@Override
	public int getMinArgs() {
		return 1;
	}

	@Override
	public int getMaxArgs() {
		return 1;
	}

	@Override
	protected void checkArguments(Term[] args) throws JasonException {
		super.checkArguments(args);
	}

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		checkArguments(args);

		Pred pred = new Pred("include");
		pred.setTerms(Arrays.asList(args));

		Agent ag = ((Include) DirectiveProcessor.getDirective("include")).process(pred, ts.getAg(), null);
		ts.getAg().importComponents(ag);
		
		return true;
	}

}
