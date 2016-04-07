
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

/**
 * Created by tobias on 07.04.16.
 */
public class Start {

    static final Logger logger = LogManager.getLogger(Start.class.getName());

    public static void main(String[] args) {

        while(true) {

            try {
                double random = Math.random()*500;
                int rounded = (int)random;

                /* sleep a random period */
                Thread.sleep(rounded);

                double rndCount = Math.random()*20;
                int roundCount = (int)rndCount;

                logMessage(roundCount);



            } catch(Exception e) {
                e.printStackTrace();
            }
        }



    }

    public static void logMessage(int count) {


        for(int i=0; i<count; i++) {

            String msg = MessageGenerator.giveRandomMessage();

            double randmod = Math.random() * 4;
            int roundmod = (int) randmod;

            if (roundmod == 0) {
                logger.info(msg);
            }

            if (roundmod == 1) {
                logger.debug(msg);
            }

            if (roundmod == 3) {
                logger.error(msg);
            }

            if (roundmod == 4) {
                logger.trace(msg);
            }
        }
    }
}
