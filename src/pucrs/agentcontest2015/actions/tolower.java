package pucrs.agentcontest2015.actions;

import jason.JasonException;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.StringTerm;
import jason.asSyntax.StringTermImpl;
import jason.asSyntax.Term;

public class tolower extends DefaultInternalAction {

	private static final long serialVersionUID = 3044142657303654485L;

	@Override
	public int getMinArgs() {
		return 2;
	}

	@Override
	public int getMaxArgs() {
		return 2;
	}

	@Override
	protected void checkArguments(Term[] args) throws JasonException {
		super.checkArguments(args);
		if (!args[0].isString())
			throw JasonException.createWrongArgument(this, "");
		if (!args[1].isVar())
			throw JasonException.createWrongArgument(this, "");
	}

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		checkArguments(args);
		StringTerm t = (StringTerm) args[0];
		return un.unifies(args[1], new StringTermImpl(t.getString().toLowerCase()));
	}
}
