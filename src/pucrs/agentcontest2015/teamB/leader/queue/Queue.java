package pucrs.agentcontest2015.teamB.leader.queue;

import java.util.Comparator;
import java.util.PriorityQueue;

public class Queue extends PriorityQueue<Action> {

	public Queue() {
		super(10, new PriorityComparator());
	}

}
