package massim.javaagents.agents;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Vector;

import massim.javaagents.Agent;
import apltk.interpreter.data.LogicBelief;
import apltk.interpreter.data.LogicGoal;
import eis.iilang.Action;
import eis.iilang.Percept;

/**
 * Simple agent which allows to test the actions. Random seed: 112358
 *			 <configuration 
				numberOfNodes="100"
				randomWeight = "0"
				gradientWeight = "0"
				optimaWeight = "100"
				blurIterations = "8"
				optimaPercentage = "5">
 * @author tobi
 *
 */
public class SimpleDebugActionAgent extends Agent {
	
	private Vector<Action> actions = new Vector<Action>();
	
	private String lastAction = "";
	private String lastActionResult = "";
	
	private HashSet<String> visibleEntities;
	private HashSet<String> neighbors;
	
	private String name;

	public SimpleDebugActionAgent(String name, String team) {
		super(name, team);
		
		this.name = name;
		
		actions.add(MarsUtil.skipAction());
		actions.add(MarsUtil.probeAction());
		actions.add(MarsUtil.inspectAction());
		actions.add(MarsUtil.rechargeAction());
		actions.add(MarsUtil.attackAction("test"));
		actions.add(MarsUtil.surveyAction());
		actions.add(MarsUtil.skipAction());
		
		actions.add(MarsUtil.buyAction("sensor"));
		
		actions.add(MarsUtil.rechargeAction());
	}

	@Override
	public void handlePercept(Percept p) {
	}

	@Override
	public Action step() {
		
		neighbors = new HashSet<String>();
		visibleEntities = new HashSet<String>();
		handlePercepts();
		
		println("Last action: "+lastAction+" lastActionResult: "+lastActionResult);
		String o = "";
		for(String s: this.visibleEntities){
			o+=s+" ";
		}
		println("I can see "+o);

		if(actions.size() > 0){
			return actions.remove(0);
		}
		else{
		
			if(lastActionResult.equals("failed_resources")){
				return MarsUtil.rechargeAction();
			}
			
			if(name.equals("agentA15")){
				return MarsUtil.attackAction("b9");
			}
			else if(name.equals("agentA4")){
				return MarsUtil.probeAction("v38");
			}
			else if(name.equals("agentA24")){
				return MarsUtil.inspectAction("b6");
			}
		}

		return MarsUtil.skipAction();
		
	}

	private void handlePercepts() {

		String position = null;
		
		// check percepts
		Collection<Percept> percepts = getAllPercepts();
		removeBeliefs("visibleEntity");
		removeBeliefs("visibleEdge");
		
		for ( Percept p : percepts ) {
			
			if ( p.getName().equals("step") ) {}
			
			else if ( p.getName().equals("visibleEntity") ) {
				LogicBelief b = MarsUtil.perceptToBelief(p);
				if ( containsBelief(b) == false ) {
					addBelief(b);
				}
				else {
				}
				
				visibleEntities.add(p.getParameters().get(0).toString());
			}
			else if ( p.getName().equals("visibleEdge") ) {
				LogicBelief b = MarsUtil.perceptToBelief(p);
				if ( containsBelief(b) == false ) {
					addBelief(b);
				}
				else {
				}
			}
			else if ( p.getName().equals("probedVertex") ) {
				LogicBelief b = MarsUtil.perceptToBelief(p);
				if ( containsBelief(b) == false ) {
//					println("I perceive the value of a vertex that I have not known before");
					addBelief(b);
					broadcastBelief(b);
				}
				else {
					//println("I already knew " + b);
				}
			}
			else if ( p.getName().equals("surveyedEdge") ) {
				LogicBelief b = MarsUtil.perceptToBelief(p);
				if ( containsBelief(b) == false ) {
//					println("I perceive the weight of an edge that I have not known before");
					addBelief(b);
					broadcastBelief(b);
				}
				else {
					//println("I already knew " + b);
				}
			}
			else if ( p.getName().equals("health")) {
				Integer health = new Integer(p.getParameters().get(0).toString());
				println("my health is " +health );
				if ( health.intValue() == 0 ) {
//					println("my health is zero. asking for help");
					broadcastBelief(new LogicBelief("iAmDisabled"));
				}
			}
			else if ( p.getName().equals("position") ) {
				position = p.getParameters().get(0).toString();
				println("I'm at "+p.getParameters().get(0).toString());
				removeBeliefs("position");
				addBelief(new LogicBelief("position",position));
			}
			else if ( p.getName().equals("energy") ) {
				Integer energy = new Integer(p.getParameters().get(0).toString());
				removeBeliefs("energy");
				addBelief(new LogicBelief("energy",energy.toString()));
			}
			else if ( p.getName().equals("maxEnergy") ) {
				Integer maxEnergy = new Integer(p.getParameters().get(0).toString());
				removeBeliefs("maxEnergy");
				addBelief(new LogicBelief("maxEnergy",maxEnergy.toString()));
			}
			else if ( p.getName().equals("money") ) {
				Integer money = new Integer(p.getParameters().get(0).toString());
				removeBeliefs("money");
				addBelief(new LogicBelief("money",money.toString()));
			}
			else if ( p.getName().equals("achievement") ) {
//				println("reached achievement " + p);
			}
			else if ( p.getName().equals("lastAction") ) {
				lastAction = p.getParameters().get(0).toString();
			}
			else if ( p.getName().equals("lastActionResult") ) {
				lastActionResult = p.getParameters().get(0).toString();
			}
		}
		
		// again for checking neighbors
		this.removeBeliefs("neighbor");
		for ( Percept p : percepts ) {
			if ( p.getName().equals("visibleEdge") ) {
				String vertex1 = p.getParameters().get(0).toString();
				String vertex2 = p.getParameters().get(1).toString();
				if ( vertex1.equals(position) ) 
					addBelief(new LogicBelief("neighbor",vertex2));
					neighbors.add(vertex2);
				if ( vertex2.equals(position) ) 
					addBelief(new LogicBelief("neighbor",vertex1));
					neighbors.add(vertex1);
			}
		}	
	}
}
