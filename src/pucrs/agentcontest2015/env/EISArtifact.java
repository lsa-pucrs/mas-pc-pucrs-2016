package pucrs.agentcontest2015.env;

import jason.JasonException;
import jason.asSyntax.Literal;

import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import cartago.AgentId;
import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import eis.EILoader;
import eis.EnvironmentInterfaceStandard;
import eis.exceptions.ActException;
import eis.exceptions.AgentException;
import eis.exceptions.EntityException;
import eis.exceptions.ManagementException;
import eis.exceptions.NoEnvironmentException;
import eis.exceptions.PerceiveException;
import eis.exceptions.RelationException;
import eis.iilang.Action;
import eis.iilang.EnvironmentState;
import eis.iilang.Parameter;
import eis.iilang.Percept;

public class EISArtifact extends Artifact {

	private Logger logger = Logger.getLogger(EISArtifact.class.getName());

	private EnvironmentInterfaceStandard ei;
	private Map<String, AgentId> agentIds;
	private Map<String, String> agentToEntity;

	private boolean receiving;

	public EISArtifact() {
	}
	
	protected void init() throws IOException {

		agentIds = new HashMap<String, AgentId>();
		agentToEntity = new HashMap<String, String>();

		ei = EILoader.fromClassName("massim.eismassim.EnvironmentInterface");

		try {
			if (ei.isInitSupported())
				ei.init(new HashMap<String, Parameter>());
			if (ei.getState() != EnvironmentState.PAUSED)
				ei.pause();
			if (ei.isStartSupported())
				ei.start();
		} catch (ManagementException e) {
			logger.log(Level.SEVERE, e.getMessage());
		}

		receiving = true;
		execInternalOp("receiving");
	}

	@OPERATION
	void register() throws EntityException {
		try {
			String agent = getOpUserId().getAgentName();
			ei.registerAgent(agent);
			ei.associateEntity(agent, agent);
			agentToEntity.put(agent, agent);
			agentIds.put(agent, getOpUserId());
			System.out.println("Registering " + agent);
		} catch (AgentException e) {
			e.printStackTrace();
		} catch (RelationException e) {
			e.printStackTrace();
		}
	}

	@OPERATION
	void register_freeconn() throws EntityException {
		try {
			String agent = getOpUserId().getAgentName();
			ei.registerAgent(agent);
			String entity = ei.getFreeEntities().iterator().next();
			ei.associateEntity(agent, entity);
			agentToEntity.put(agent, entity);
			agentIds.put(agent, getOpUserId());
			System.out.println("Registering " + agent + " to entity " + entity);
		} catch (AgentException e) {
			e.printStackTrace();
		} catch (RelationException e) {
			e.printStackTrace();
		}
	}
	
	@OPERATION
	void action(String action) {
		try {
			String agent = getOpUserId().getAgentName();
			Action a = new Action(action);
			ei.performAction(agent, a, agentToEntity.get(agent));
		} catch (ActException e) {
			e.printStackTrace();
		}
	}

	@OPERATION
	void action(String action, Object... params) {
		try {
			String agent = getOpUserId().getAgentName();
			LinkedList<Parameter> llparams = Translator.parametersToIdentifiers(params);
			Action a = new Action(action, llparams);
			ei.performAction(agent, a, agentToEntity.get(agent));
		} catch (ActException e) {
			e.printStackTrace();
		}
	}
	
	@INTERNAL_OPERATION
	void receiving() {
		while (receiving) {
			for (String agent : ei.getAgents()) {
				try {
					Collection<Percept> percepts = ei.getAllPercepts(agent).get(agentToEntity.get(agent));
					for (Percept percept : percepts) {
						String name = percept.getName();
						Literal literal = Translator.perceptToLiteral(percept);
						signal(agentIds.get(agent), name, (Object[]) literal.getTermsArray());
					}
				} catch (PerceiveException e) {
				} catch (NoEnvironmentException e) {
				} catch (JasonException e) {
					e.printStackTrace();
				}
			}
			await_time(500);
		}
	}

	@OPERATION
	void stopReceiving() {
		receiving = false;
	}

}