// CArtAgO artifact code for project contract_net_protocol

package pucrs.agentcontest2015.cnp;

import java.util.logging.Logger;

import pucrs.agentcontest2015.env.EISArtifact;
import jason.asSyntax.Literal;
import cartago.*;

public class TaskBoard extends Artifact {
	
	private Logger logger = Logger.getLogger(TaskBoard.class.getName());
	
	private int taskId;
	
	void init(){
		logger.info("TaskBoard Artifact created!");
		taskId = 0;
	}
	
	@OPERATION void announce(String taskDescr, int duration, OpFeedbackParam<String> id){
		taskId++;
		try {
			String artifactName = "cnp_board_"+taskId;
			makeArtifact(artifactName, "pucrs.agentcontest2015.cnp.ContractNetBoard", new ArtifactConfig(taskDescr,duration));
			defineObsProperty("task", Literal.parseLiteral(taskDescr), artifactName);
			id.set(artifactName);
		} catch (Exception ex){
			logger.info("announce_failed");
		}
	}
	
	@OPERATION void clear(String artifactName){
		this.removeObsPropertyByTemplate("task", null, artifactName);
	}
	
}