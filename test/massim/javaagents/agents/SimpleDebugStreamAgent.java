package massim.javaagents.agents;

import eis.iilang.Action;
import eis.iilang.Percept;
import massim.javaagents.Agent;

import java.io.*;
import java.util.Collection;

/**
 * Created by ta10 on 09.04.15.
 */
public class SimpleDebugStreamAgent extends Agent {

    private FileWriter out;
    private BufferedReader in;

    private int lastStep = -1;
    private Action lastAction;
    private int simCounter = 1;

    private String name = "";

    private File logpath;
    private File logfile;
    private File actionconf;

    /**
     * Initializes an agent with a given name. Ensures that the name is unique.
     *
     * @param name is the name of the agent
     * @param team is the team of the agent
     */
    public SimpleDebugStreamAgent(String name, String team) {

        super(name, team);

        this.name = name;

        createIO();
    }

    private void createIO() {
        logpath = new File("log/"+System.currentTimeMillis()/(1000));
        logfile = new File(logpath+"/"+name+"-"+simCounter);
        actionconf = new File("conf/team-b/actionconf/"+name+"-"+simCounter);

        logpath.mkdirs();

        if(!actionconf.exists()) try {
            actionconf.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }

        if(!logfile.exists()) try {
            logfile.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {

            out = new FileWriter(logfile);
            out.write(name + " starting log at " + System.currentTimeMillis());

            in = new BufferedReader(new FileReader(actionconf));

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Action step() {

        boolean newStep = true;

        //log percepts
        if(out != null){

            try {
                out.write("Log: ");
            } catch (IOException e) {
                e.printStackTrace();
            }

            Collection<Percept> percepts = getAllPercepts();

            for(Percept p: percepts){
                try {
                    out.write(p.toProlog());
//                	out.write(p.toXML());
                } catch (IOException e) {
                    e.printStackTrace();
                }

                if(p.getName().equals("step")){
                    int step = new Integer(p.getParameters().get(0).toProlog()).intValue();

                    if(step < lastStep){
                        simCounter++;
                        createIO();
                    }
                    else if(step == lastStep){
                        newStep = false;
                    }
                    lastStep = step;
                }

            }
            try {
                out.write("\n \n");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        //get action and execute it
        if(in != null && newStep){
            String action, name = "", param = "";
            try {

                if ((action = in.readLine()) == null) {
                    in.close();
                    in = null;
                    return lastAction=CityUtil.action("skip");
                }
                else{
                	int idx = action.indexOf(" ");
                	if(idx != -1){
                		name = action.substring(0, idx);
                		param = action.substring(idx+1);
                        println(getName()+": Executing: "+name+" "+param);
                        return lastAction=CityUtil.action(name, param);
                    }
                    else{
                    	name = action;
                        println(getName()+": Executing: "+name);
                        return lastAction=CityUtil.action(name);
                    }
                	
                	/*
                    String[] parts = action.split(" ");
                    name = parts[0];
                    if(parts.length > 1){
                        param = parts[1];
                        System.out.println(getName()+": Executing: "+name+" "+param);
                        return CityUtil.action(name, param);
                    }
                    else{
                        System.out.println(getName()+": Executing: "+name);
                        return CityUtil.action(name);
                    }
                    */
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        else{ //no new step or input closed, retry latest action
            if (lastAction != null) {
                println("retry last action");
                return lastAction;
            }
        }

        return lastAction=CityUtil.action("skip");
    }

    @Override
    public void handlePercept(Percept p) {}
}
