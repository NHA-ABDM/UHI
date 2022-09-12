package in.gov.abdm.uhi.EUABookingService.notification;

import java.util.concurrent.ExecutionException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;
@Service
public class PushNotificationService {
	
    private Logger logger = LogManager.getLogger(PushNotificationService.class);
    
    private FCMService fcmService;
    
    public PushNotificationService(FCMService fcmService) {
        this.fcmService = fcmService;
    }
    
    
    public void sendPushNotificationToToken(PushNotificationRequest request) throws InterruptedException, ExecutionException {
       
            fcmService.sendMessageToToken(request);
       
    }
   
}