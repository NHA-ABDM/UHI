package in.gov.abdm.uhi.hspa.service;

import in.gov.abdm.uhi.hspa.dto.PushNotificationRequestDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;

@Service
public class PushNotificationService {

    private final Logger logger = LoggerFactory.getLogger(PushNotificationService.class);

    private final FCMService fcmService;

    public PushNotificationService(FCMService fcmService) {
        this.fcmService = fcmService;
    }


    public void sendPushNotificationToToken(PushNotificationRequestDTO request) throws ExecutionException, InterruptedException {

        fcmService.sendMessageToToken(request);

    }
}
   
