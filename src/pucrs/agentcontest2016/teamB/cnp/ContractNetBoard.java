// CArtAgO artifact code for project contract_net_protocol

package pucrs.agentcontest2016.teamB.cnp;

import jason.asSyntax.Literal;

import java.util.ArrayList;
import java.util.List;

import cartago.*;

public class ContractNetBoard extends Artifact {
	
	private List<Bid> bids;
	private int bidId;
	
	
	void init(String taskDescr, long duration){
		this.defineObsProperty("task_description", taskDescr);
		long started = System.currentTimeMillis();
		this.defineObsProperty("created", started);
		long deadline = started + duration;
		this.defineObsProperty("deadline", deadline);
		this.defineObsProperty("state","open");
		bids = new ArrayList<Bid>();
		bidId = 0;
		this.execInternalOp("checkDeadline",duration);
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
		getObsProperty("state").updateValue("closed");
		log("bidding stage closed.");
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
		return this.getObsProperty("state").stringValue().equals("closed");
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
		//public String toString(){ return descr; }
	}
	
}