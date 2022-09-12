package in.gov.abdm.uhi.hspa.service;

import com.google.firebase.messaging.*;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import in.gov.abdm.uhi.hspa.dto.PushNotificationRequestDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class FCMService {
    private final Logger logger = LoggerFactory.getLogger(FCMService.class);
    
    
    public void sendMessageToToken(PushNotificationRequestDTO request)
            throws InterruptedException, ExecutionException {
        Message message = getPreconfiguredMessageToToken(request);
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String jsonOutput = gson.toJson(message);
        String response = sendAndGetResponse(message);
        logger.info("Sent message to token. Device token: " + request.getToken() + ", " + response);
    }
    
    private String sendAndGetResponse(Message message) throws InterruptedException, ExecutionException {
        return FirebaseMessaging.getInstance().sendAsync(message).get();
    }

    private AndroidConfig getAndroidConfig(String topic) {
        return AndroidConfig.builder()
                .setTtl(Duration.ofMinutes(2).toMillis()).setCollapseKey(topic)
                .setPriority(AndroidConfig.Priority.HIGH)
                .setNotification(AndroidNotification.builder()
                      .setTag(topic).build()).build();
    }

    private ApnsConfig getApnsConfig(String topic) {
        return ApnsConfig.builder()
                .setAps(Aps.builder().setCategory(topic).setThreadId(topic).build()).build();
    }
    private Message getPreconfiguredMessageToToken(PushNotificationRequestDTO request) {
        return getPreconfiguredMessageBuilder(request).setToken(request.getToken())
                .build();
    }
    private Message getPreconfiguredMessageWithoutData(PushNotificationRequestDTO request) {
        return getPreconfiguredMessageBuilder(request).setTopic(request.getTopic())
                .build();
    }
    private Message getPreconfiguredMessageWithData(Map<String, String> data, PushNotificationRequestDTO request) {
        return getPreconfiguredMessageBuilder(request).putAllData(data).setToken(request.getToken())
                .build();
    }
   
	private Message.Builder getPreconfiguredMessageBuilder(PushNotificationRequestDTO request) {
        AndroidConfig androidConfig = getAndroidConfig(request.getTopic());
        ApnsConfig apnsConfig = getApnsConfig(request.getTopic());



        return Message.builder()
                .setApnsConfig(apnsConfig).setAndroidConfig(androidConfig).setNotification(
                		Notification
                        .builder()
                        .setTitle(request.getTitle())
                        .setBody(request.getMessage())
                        .build())

                        .putData("SenderabhaAddress", request.getSenderAbhaAddress())
                        .putData("ReceiverabhaAddress", request.getReceiverAbhaAddress())
                        .putData("ProviderUri",request.getProviderUri())
                        .putData("type", request.getType())
                        .putData("senderName", request.getTitle())
                        .putData("gender", request.getGender())
                        .putData("contentType", request.getContentType())
                        .putData("sharedKey", request.getSharedKey());
    }
}