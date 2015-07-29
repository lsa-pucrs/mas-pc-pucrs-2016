package massim.javaagents.agents;

import java.util.Collection;

import massim.javaagents.Agent;
import eis.iilang.Action;
import eis.iilang.Percept;

public class SimpleSkippingAgent extends Agent {

	public SimpleSkippingAgent(String name, String team) {
		super(name, team);
	}

	@Override
	public void handlePercept(Percept p) {
		
	}

	@Override
	public Action step() {
		
		Collection<Percept> percepts = getAllPercepts();
		for(Percept p : percepts){
			if(p.getName().equals("position")){
				println("I'm at "+p.getParameters().get(0).toString());
			}
		}
		
		return MarsUtil.skipAction();
		
	}
}
