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
	private String team;
	private Map<String, String> connections;
	private Map<String, AgentId> agentIds;

	private boolean receiving;

	public EISArtifact() {
	}

	protected void init() {
	}

	protected void init(String team) throws IOException {

		connections = new HashMap<String, String>();
		agentIds = new HashMap<String, AgentId>();

		this.team = "connection" + team.toUpperCase();

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
		String agentName = getOpUserId().getAgentName();

		// Try to find an entity of Team X to allocate agent
		for (String entity : ei.getFreeEntities()) {
			if (entity.startsWith(this.team)) {
				try {
					ei.registerAgent(agentName);
					ei.associateEntity(agentName, entity);
					agentIds.put(agentName, getOpUserId());
					connections.put(agentName, entity);
					System.out.println("Registering " + agentName + " w/ " + entity);
					break;
				} catch (AgentException e) {
					logger.log(Level.SEVERE, e.getMessage());
				} catch (RelationException e) {
					logger.log(Level.SEVERE, e.getMessage());
				}
			}
		}
	}

	@OPERATION
	void action(String action, Object... params) {
		try {
			LinkedList<Parameter> llparams = Translator.parametersToIdentifiers(params);
			Action a = new Action(action, llparams);
			String agent = getOpUserId().getAgentName();
			String entity = connections.get(agent);
			ei.performAction(agent, a, entity);
		} catch (ActException e) {
			e.printStackTrace();
		}
	}

	@INTERNAL_OPERATION
	void receiving() {
		while (receiving) {
			Set<String> agents = connections.keySet();
			for (String agent : agents) {
				try {
					String entity = connections.get(agent);
					Collection<Percept> percepts = ei.getAllPercepts(agent).get(entity);
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