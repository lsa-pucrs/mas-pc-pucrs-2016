package pucrs.agentcontest2015.teamB.env;

import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.Literal;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import massim.competition2015.scenario.Location;
import pucrs.agentcontest2015.teamB.env.EISArtifact;
import cartago.AgentId;
import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import cartago.ObsProperty;
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
import eis.iilang.ParameterList;
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

		String maps[] = new String[] { "clausthal", "hannover", "london" };

		MapHelper.init(maps[0], 0.001, 0.0002);

		try {
			ei = EILoader.fromClassName("massim.eismassim.EnvironmentInterface");
			if (ei.isInitSupported())
				ei.init(new HashMap<String, Parameter>());
			if (ei.getState() != EnvironmentState.PAUSED)
				ei.pause();
			if (ei.isStartSupported())
				ei.start();
		} catch (IOException | ManagementException e) {
			e.printStackTrace();
		}
	}

	protected void init() throws IOException {
		receiving = true;
		execInternalOp("receiving");
	}
	
/*
	private static AgentId leader;
	
	@OPERATION
	void register_leader() throws EntityException {
		leader = getOpUserId();
		System.out.println("Registering leader: " + leader.getAgentName());
	}
*/

	@OPERATION
	void register(String entity)  {
		try {
			String agent = getOpUserId().getAgentName();
			ei.registerAgent(agent);
			ei.associateEntity(agent, entity);
			agentToEntity.put(agent, entity);
			agentIds.put(agent, getOpUserId());
			logger = Logger.getLogger(EISArtifact.class.getName()+"_"+agent);
			logger.info("Registering " + agent + " to entity " + entity);
			signal(agentIds.get(agent), "serverName", Literal.parseLiteral(entity.substring(10).toLowerCase()));
		} catch (Exception e) {
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
			signal(agentIds.get(agent), "serverName", Literal.parseLiteral(entity.substring(10).toLowerCase()));
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
	void receiving() throws JasonException {
		// Set<Percept> leader_percepts = new HashSet<Percept>();
		boolean filterIsFiltered = false;
		while (receiving) {
			// leader_percepts.clear();
			for (String agent : ei.getAgents()) {
				try {
					Collection<Percept> percepts = ei.getAllPercepts(agent).get(agentToEntity.get(agent));
					// leader_percepts.addAll(agentise(agent, percepts));
					filterLocations(agent, percepts);
					
					// TODO change map when round finish
					
					for (Percept percept : filter(percepts)) {
						String name = percept.getName();
						/*Verifying available items in a nearby shop
						if(name.equals("shop")){
							for(Parameter p: percept.getParameters())
								if(p.toString().contains("availableItem"))
									pinShopAvailableItems(percept, p);
						}*/
						Literal literal = Translator.perceptToLiteral(percept);
						signal(agentIds.get(agent), name, (Object[]) literal.getTermsArray());
					}
				} catch (PerceiveException | NoEnvironmentException | JasonException e) {
					e.printStackTrace();
				}
			}
			/* Filtering the filter */
			if(!filterIsFiltered){
				for(String f:another_agent_filter.keySet())
					another_agent_filter.put(f, true);
				
				filterIsFiltered = true;
			}
			
			signal("ok");
/*
			for (Percept percept : leader_percepts) {
				String name = percept.getName();
				Literal literal = Translator.perceptToLiteral(percept);
				signal(leader, name, (Object[]) literal.getTermsArray());
			}
*/
			/* exemplo de propriedade observavel
			private String propertyName = "set_a_name"; //nome da propriedade
			defineObsProperty(propertyName, 0); //define a new observable property and sets initial value
			...
			ObsProperty prop = getObsProperty(propertyName); //get current value of observable property
			prop.updateValues(0); //updates current value of property (I am almost sure that this command generates a signal automatically)
			signal(propertyName);
			*/
			await_time(100);
		}
	}

	@OPERATION
	void reset() {

	}

	@OPERATION
	void stopReceiving() {
		receiving = false;
	}
/*
	static List<String> agentise = Arrays.asList(new String[]{
		"charge",
		"fPosition",
		"inFacility",
		"item",
		"lastAction",
		"lastActionParam",
		"lastActionResult",
		"lat",
		"load",
		"lon",
		"requestAction",
		"role",
		"route",
		"routeLength",
	});

	public static List<Percept> agentise( String agent, Collection<Percept> perceptions ){
		// TODO change entity name (a1) to Jason agent name (vehicle1)
		List<Percept> list = new ArrayList<Percept>();
		for(Percept perception : perceptions){
			if(agentise.contains(perception.getName())){
				LinkedList<Parameter> parameters = perception.getClonedParameters();
				parameters.addFirst(new Identifier(agent));
				perception = (Percept) perception.clone();
				perception.setParameters(parameters);
			}
			list.add(perception);
		}
		return list;
	}
*/	
	static Map<String, Boolean> another_agent_filter = new HashMap<String, Boolean>();
	static{
		another_agent_filter.put("dump", false);
		another_agent_filter.put("storage", false);
		another_agent_filter.put("workshop", false);
		another_agent_filter.put("chargingStation", false);
	}
	
	static List<String> agent_filter = Arrays.asList(new String[]{
		"charge",
//		"entity",
//		"fPosition",
		"inFacility",
		"item",
		"lastAction",
//		"lastActionParam",
//		"lastActionResult",
//		"lat",
		"load",
//		"lon",
//		"requestAction",
		"role",
		"step",
//		"route",
//		"routeLength",
//		"team",
//		"timestamp",		

		"steps",
		"jobTaken",
		"simEnd",		
		"auctionJob",		
		"pricedJob",
		"product",		
		"shop",
		"storage",
		"workshop",
		"chargingStation",
		"dump",
	});
	
	public static List<Percept> filter( Collection<Percept> perceptions ){
		List<Percept> list = new ArrayList<Percept>();
		for(Percept perception : perceptions){
			if(agent_filter.contains(perception.getName())){
				/* Filtering the filter */
				if(another_agent_filter.containsKey(perception.getName()) && !another_agent_filter.get(perception.getName()))
					continue;
				
				list.add(perception);
			}
		}
		return list;
	}
	
	static List<String> location_perceptions = Arrays.asList(new String[] { "shop", "storage", "workshop", "chargingStation", "dump", "entity" });

	private void filterLocations(String agent, Collection<Percept> perceptions) {
		double agLat = Double.NaN, agLon = Double.NaN;
		for (Percept perception : perceptions) {
			if(perception.getName().equals("lon")){
				agLon = Double.parseDouble(perception.getParameters().get(0).toString());
			}
			if(perception.getName().equals("lat")){
				agLat = Double.parseDouble(perception.getParameters().get(0).toString());
			}
			if (location_perceptions.contains(perception.getName())) {
				boolean isEntity = perception.getName().equals("entity"); // Second parameter of entity is the team. :(
				LinkedList<Parameter> parameters = perception.getParameters();
				String facility = parameters.get(0).toString();
				if (!MapHelper.hasLocation(facility)) {
					String local = parameters.get(0).toString();
					double lat = Double.parseDouble(parameters.get(isEntity ? 2 : 1).toString());
					double lon = Double.parseDouble(parameters.get(isEntity ? 3 : 2).toString());
					MapHelper.addLocation(local, new Location(lon, lat));
				}
			}
		}
		if(!Double.isNaN(agLat) && !Double.isNaN(agLon)){
			MapHelper.addLocation(agent, new Location(agLon, agLat));
		}
	}
	
	/**
	 * This method defines/updates an observed property for consulting available items (price and amount) in the shops. 
	 * 
	 * @param Percept percept
	 * @param Parameter param
	 */
	public void pinShopAvailableItems(Percept percept, Parameter param) {
		String propertyName = "availableItems";
		ObsProperty property = getObsProperty(propertyName);
		if (property == null) {
			defineObsProperty(propertyName, percept.getParameters().get(0), new ParameterList());
			property = getObsProperty(propertyName);
		}

		property.updateValues(percept.getParameters().get(0), param);
		signal(propertyName);
	}

}