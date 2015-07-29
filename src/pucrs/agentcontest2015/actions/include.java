package pucrs.agentcontest2015.actions;

import jason.JasonException;
import jason.asSemantics.Agent;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.Plan;
import jason.asSyntax.Pred;
import jason.asSyntax.Term;
import jason.asSyntax.directives.DirectiveProcessor;
import jason.asSyntax.directives.Include;
import jason.bb.BeliefBase;

import java.util.Arrays;

public class include extends DefaultInternalAction {

	private static final long serialVersionUID = 3044142657303654485L;

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
	
    public void importComponents(Agent from, Agent to) throws JasonException {
        if (from != null) {
            for (Literal b: from.getInitialBels()){
            	b.addAnnot(BeliefBase.TSelf);
            	to.getBB().add(b);
            }
            for (Plan p: from.getPL()) 
                to.getPL().add(p, false);
        }
    }

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		checkArguments(args);

		Pred pred = new Pred("include");
		pred.setTerms(Arrays.asList(args));

		Agent ag = ((Include) DirectiveProcessor.getDirective("include")).process(pred, ts.getAg(), null);
		importComponents(ag, ts.getAg());
		
		return true;
	}

}
