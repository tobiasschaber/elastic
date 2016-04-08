import java.util.ArrayList;
import java.util.List;

/**
 * Created by tobias on 07.04.16.
 */
public class MessageGenerator {

    private static List<String> messages = new ArrayList<String>();

    static {
        messages.add("User logged in into the application");
        messages.add("Reading data from cache");
        messages.add("Writing data into cache");
        messages.add("Pushing new events to database");
        messages.add("Reading new events from database");
        messages.add("Waiting for new client connections");
        messages.add("Closed client connection");
        messages.add("new client registered");
        messages.add("deployed new plugin");
        messages.add("enabled rest interface on port 1422");
        messages.add("disabled rest interface due to heavy load");
        messages.add("incoming order");
        messages.add("order processing successful");
        messages.add("order processing failed");
        messages.add("order rejected due to fraud system");
        messages.add("order waiting for payment");
    }

    public static String giveRandomMessage() {

        double random = Math.random()*(messages.size()-1);
        int rand = (int)Math.round(random);

        return messages.get(rand);




    }
}
