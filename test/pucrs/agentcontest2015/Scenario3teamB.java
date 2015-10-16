package pucrs.agentcontest2015;

import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.competition2015.monitor.GraphMonitor;
import massim.server.Server;
import massim.test.InvalidConfigurationException;

public class Scenario3teamB {

	@Before
	public void setUp() {
		
		try {
			JaCaMoLauncher runner2 = new JaCaMoLauncher();
			runner2.init(new String[] { "test/pucrs/agentcontest2015/teamB/scenario1.jcm" });
			runner2.getProject().addSourcePath("./src/pucrs/agentcontest2015/teamB/agt");
			runner2.create();
			runner2.start();
			runner2.waitEnd();
			runner2.finish();
		} catch (JasonException e) {
			e.printStackTrace();
		}
	}

	@Test
	public void run() {
	}

}
