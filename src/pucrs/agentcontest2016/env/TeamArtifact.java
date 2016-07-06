package pucrs.agentcontest2016.env;

import jason.asSyntax.Term;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import cartago.Artifact;

public class TeamArtifact extends Artifact {

	private static Logger logger = Logger.getLogger(TeamArtifact.class.getName());
	private static Map<String, List<Term>> shopItemsPrice = new HashMap<String, List<Term>>();
	
	void init(){
		logger.info("Team Artifact has been created!");
	}
	
	public synchronized static void addShopItemsPrice(String shopId, List<Term> itemsPrice){
		//logger.info("$> Team Artifact (Shop - Items Price): " + shopId);
		if(shopItemsPrice.containsKey(shopId)){
			
		} else {
			shopItemsPrice.put(shopId, itemsPrice);
		}
	}
}