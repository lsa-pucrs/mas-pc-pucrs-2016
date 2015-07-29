package massim.javaagents.agents;

import eis.iilang.Action;
import eis.iilang.Identifier;
import eis.iilang.Parameter;
import eis.iilang.Percept;

/**
 * Created by ta10 on 09.04.15.
 */
public class CityUtil {

    //TODO 2015: implement if needed

    static public Action action(String name){
        return new Action(name);
    }

    static public Action action(String name, String param){
        return new Action(name, new Identifier(param));
    }

    static public Action gotoAction(){
        return new Action("goto");
    }
}
