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
	private int bidId;
	
	void init(String taskDescr, long duration){
		logger = Logger.getLogger(ContractNetBoard.class.getName()+"_"+taskDescr);
		this.defineObsProperty("task_description", taskDescr);
		long started = System.currentTimeMillis();
		this.defineObsProperty("created", started);
		long deadline = started + duration;
		this.defineObsProperty("deadline", deadline);
		this.defineObsProperty("state","open");
		bids = new ArrayList<Bid>();
		bidId = 0;
		this.execInternalOp("checkDeadline", duration);
		this.execInternalOp("checkAllBids");
	}
	
	@OPERATION void bid(int bid, OpFeedbackParam<Integer> id){
		if (getObsProperty("state").stringValue().equals("open")){
			bidId++;
			bids.add(new Bid(bidId,bid));
			id.set(bidId);
		} else {
			this.failed("cnp_closed");
		}
	}

	@OPERATION void award(int bidId, String Task, String Items, String JobId, String StorageId){
		this.defineObsProperty("winner", bidId,Task,Literal.parseLiteral(Items),Literal.parseLiteral(JobId),Literal.parseLiteral(StorageId));
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
			aux[i] = Literal.parseLiteral("bid("+p.getValue()+","+p.getId()+")");
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
		
		private int id;
		private int value;
		
		public Bid(int id, int value){
			this.value = value;
			this.id = id;
		}
		
		public int getId(){ return id; }
		public int getValue(){ return value; }
	}
	
}
