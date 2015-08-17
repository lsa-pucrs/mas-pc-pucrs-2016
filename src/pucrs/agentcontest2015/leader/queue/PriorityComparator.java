package pucrs.agentcontest2015.leader.queue;

import java.util.Comparator;

public class PriorityComparator implements Comparator<Action> {

	@Override
	public int compare(Action o1, Action o2) {
		return o1.getGivenPriority() - o2.getGivenPriority();
	}
	
}
