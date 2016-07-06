package pucrs.agentcontest2016;

import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.server.Server;

public class Scenario2 {
	
	public static void main(String[] args) throws InterruptedException{
		new Scenario2().run();
	}

	@Test
	public void run() throws InterruptedException {

		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					Server.main(new String[] { "--conf", "conf/test-1agent/2015-tests-1sims.xml" });
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();
		
		Thread.sleep(1000);

		new Thread(new Runnable() {
			@Override
			public void run() {

				try {
					JaCaMoLauncher runner = new JaCaMoLauncher();
					runner.init(new String[] { "test/pucrs/agentcontest2015/scenario2.jcm" });
					runner.getProject().addSourcePath("./src/pucrs/agentcontest2015/agt");
					runner.create();
					runner.start();
					runner.waitEnd();
					runner.finish();
				} catch (JasonException e) {
					e.printStackTrace();
				}
			}
		}).start();
		
		while(true){
			Thread.sleep(500);
		}
		
	}

}
