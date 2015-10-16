package pucrs.agentcontest2015.teamB.leader.queue;

public class Action {

	private Action mustBeAfter;
	private Action mustBeBefore;
	private int givenPriority;

	public Action() {

	}

	public Action(int givenPriority) {
		this.givenPriority = givenPriority;
	}

	public Action getMustBeAfter() {
		return mustBeAfter;
	}

	public void setMustBeAfter(Action mustBeAfter) {
		this.mustBeAfter = mustBeAfter;
	}

	public Action getMustBeBefore() {
		return mustBeBefore;
	}

	public void setMustBeBefore(Action mustBeBefore) {
		this.mustBeBefore = mustBeBefore;
	}

	public int getGivenPriority() {
		return givenPriority;
	}

}
