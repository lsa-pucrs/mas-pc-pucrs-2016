package pucrs.agentcontest2015;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.server.Server;
import massim.test.InvalidConfigurationException;

import org.junit.Before;
import org.junit.Test;

public class ScenarioLeader {

	@Before
	public void setUp() {

		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					Server.main(new String[] { "--conf", "conf/test-completescenario/2015-complete-3sims.xml" });
				} catch (InvalidConfigurationException e) {
					e.printStackTrace();
				}
			}
		}).start();

		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		try {
			JaCaMoLauncher runner = new JaCaMoLauncher();
			runner.init(new String[] { "test/pucrs/agentcontest2015/scenarioleader.jcm" });
			runner.getProject().addSourcePath("./src/pucrs/agentcontest2015/agt");
			runner.create();
			runner.start();
			runner.waitEnd();
			runner.finish();
		} catch (JasonException e) {
			e.printStackTrace();
		}

	}

	@Test
	public void run() {
	}

}