package pucrs.agentcontest2015.env;

import jason.architecture.AgArch;

import java.util.logging.Logger;
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;

import pucrs.agentcontest2015.leader.queue.Action;
import pucrs.agentcontest2015.leader.queue.Queue;

public class LeaderAgArch extends AgArch {

	private Logger logger = Logger.getLogger(LeaderAgArch.class.getName());
	
	public LeaderAgArch() {;
	}

	public static LeaderAgArch getLeaderAgArch(AgArch agArch) {
		agArch = agArch.getFirstAgArch();
		while (agArch != null) {
			if (agArch.getClass().equals(LeaderAgArch.class)) {
				return (LeaderAgArch) agArch;
			}
			agArch = agArch.getNextAgArch();
		}
		return null;
	}

}
