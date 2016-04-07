/**
 * Created by tobias on 07.04.16.
 */
public class MessageGenerator {

    private static String[] messages = new String[11];

    static {
        messages[0] = "User logged in into the application";
        messages[1] = "Reading data from cache";
        messages[2] = "Writing data into cache";
        messages[3] = "Pushing new events to database";
        messages[4] = "Reading new events from database";
        messages[5] = "Waiting for new client connections";
        messages[6] = "Closed client connection";
        messages[7] = "new client registered";
        messages[8] = "deployed new plugin";
        messages[9] = "enabled rest interface on port 1422";
        messages[10] = "disabled rest interface due to heavy load";



    }

    public static String giveRandomMessage() {

        double random = Math.random()*10;
        int rand = (int)Math.round(random);

        return messages[rand];




    }
}
