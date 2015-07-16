package pucrs.agentcontest2015.env;

import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.Literal;

import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
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

	private static EnvironmentInterfaceStandard ei;
	private static Map<String, AgentId> agentIds;
	private static Map<String, String> agentToEntity;

	private boolean receiving;

	public EISArtifact() throws IOException {
		agentIds = new ConcurrentHashMap<String, AgentId>();
		agentToEntity = new ConcurrentHashMap<String, String>();
		
		try {
			ei = EILoader.fromClassName("massim.eismassim.EnvironmentInterface");
			if (ei.isInitSupported())
				ei.init(new HashMap<String, Parameter>());
			if (ei.getState() != EnvironmentState.PAUSED)
				ei.pause();
			if (ei.isStartSupported())
				ei.start();
		} catch (IOException e) {
		} catch (ManagementException e) {
		}
	}

	protected void init() throws IOException {
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
	
	public static void action(String agent, String action) throws NoValueException {
		try {
			Action a = Translator.literalToAction(action);
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
			await_time(200);
		}
	}

	@OPERATION
	void stopReceiving() {
		receiving = false;
	}

}