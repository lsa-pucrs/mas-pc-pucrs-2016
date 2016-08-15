// CArtAgO artifact code for project contract_net_protocol

package pucrs.agentcontest2016.cnp;

import jason.asSyntax.Literal;
import pucrs.agentcontest2016.env.EISArtifact;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import cartago.*;

public class ContractNetBoard extends Artifact {
	
	private Logger logger = null;
	
	private List<Bid> bids;
	
	void init(String taskDescr, long duration){
		logger = Logger.getLogger(ContractNetBoard.class.getName()+"_"+taskDescr);
		this.defineObsProperty("task_description", taskDescr);
		long started = System.currentTimeMillis();
		this.defineObsProperty("created", started);
		long deadline = started + duration;
		this.defineObsProperty("deadline", deadline);
		this.defineObsProperty("state","open");
		bids = new ArrayList<Bid>();
		this.execInternalOp("checkDeadline", duration);
		this.execInternalOp("checkAllBids");
	}
	
	@OPERATION void bid(int bid, String agent){
		if (getObsProperty("state").stringValue().equals("open")){
			bids.add(new Bid(agent,bid));
		} else {
			this.failed("cnp_closed");
		}
	}
	
	@INTERNAL_OPERATION void checkDeadline(long dt){
		await_time(dt);
		if(!isClosed()){
			getObsProperty("state").updateValue("closed");
			logger.info("bidding stage closed by deadline.");
		}
	}
	
	@INTERNAL_OPERATION void checkAllBids(){
		while(!isClosed() && !allAgentsMadeTheirBid()){
			await_time(50);
		}
		if(!isClosed()){
			getObsProperty("state").updateValue("closed");
			logger.info("bidding stage closed by all agents bids.");
		}
	}
	
	@OPERATION void getBids(OpFeedbackParam<Literal[]> bidList){
		await("biddingClosed");
		int i = 0;
		Literal[] aux= new Literal[bids.size()];
		for (Bid p: bids){
			aux[i] = Literal.parseLiteral("bid("+p.getValue()+","+p.getAgent()+")");
			i++;
		}
		bidList.set(aux);
	}
	
	@GUARD boolean biddingClosed(){
		return isClosed();
	}
	
	private boolean isClosed(){
		return this.getObsProperty("state").stringValue().equals("closed");		
	}
	
	private boolean allAgentsMadeTheirBid(){
		 return bids.size() == EISArtifact.getRegisteredAgents().size();
	}
	
	static public class Bid {
		
		private String agent;
		private int value;
		
		public Bid(String agent, int value){
			this.value = value;
			this.agent = agent;
		}
		
		public String getAgent(){ return agent; }
		public int getValue(){ return value; }
	}
	
}
