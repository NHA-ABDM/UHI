package in.gov.abdm.FcmNotification.Notification.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import in.gov.abdm.FcmNotification.Notification.dto.CancelOrderDTO;
import in.gov.abdm.FcmNotification.Notification.dto.PushNotificationRequestDTO;
import in.gov.abdm.FcmNotification.Notification.model.SharedKeyModel;
import in.gov.abdm.FcmNotification.Notification.model.UserTokenModel;
import in.gov.abdm.FcmNotification.Notification.repo.SharedKeyRepository;
import in.gov.abdm.FcmNotification.Notification.repo.UserTokenRepository;
import in.gov.abdm.FcmNotification.Notification.utils.ConstantsUtils;
import in.gov.abdm.uhi.common.dto.Request;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class NotificationService {

    final UserTokenRepository userTokenRepository;
    final SharedKeyRepository sharedKeyRepository;
    final PushNotificationService pushNotificationService;
    private final Logger LOGGER = LoggerFactory.getLogger(PushNotificationService.class);
    @Value("${spring.media.type.text}")
    private String mediaTypeText;
    @Value("${spring.content.message}")
    private String contentMessage;
    @Value("${spring.content.message.cancel}")
    private String contentMessageCancel;
    @Value("${spring.content.message.cancel1}")
    private String contentMessageCancel1;
    @Value("${spring.content.title.cancel}")
    private String contentTitleCancel;

    public NotificationService(UserTokenRepository userTokenRepository, SharedKeyRepository sharedKeyRepository, PushNotificationService pushNotificationService) {
        this.userTokenRepository = userTokenRepository;
        this.sharedKeyRepository = sharedKeyRepository;
        this.pushNotificationService = pushNotificationService;
    }

    public void sendNotificationToReceiver(Request request) throws ExecutionException, InterruptedException {
        String receiver = request.getMessage().getIntent().getChat().getReceiver().getPerson().getId();
        List<UserTokenModel> userTokenModelByName = getUserTokenByName(receiver);
        sendExtractedDataAsNotification(request, receiver, userTokenModelByName);
    }

    public List<UserTokenModel> getUserTokenByName(String userName) {
        return userTokenRepository.findByUserName(userName);
    }

    private void sendExtractedDataAsNotification(Request request, String receiver, List<UserTokenModel> userTokenModelByName) throws ExecutionException, InterruptedException {
        String sender = request.getMessage().getIntent().getChat().getSender().getPerson().getId();

        List<SharedKeyModel> lsk = getSharedKeyDetails(sender);
        String sharedKey = "";
        if (!lsk.isEmpty()) {
            sharedKey = lsk.get(0).getPublicKey();
        }
        for (UserTokenModel token : userTokenModelByName) {
            if (token.getToken() != null) {
                prepareSendNotification(request, receiver, sharedKey, token);
            }
        }
    }

    public List<SharedKeyModel> getSharedKeyDetails(String userName) {
        return sharedKeyRepository.findByUserName(userName);
    }

    private void prepareSendNotification(Request request, String receiver, String sharedKey, UserTokenModel token) throws ExecutionException, InterruptedException {
        String tokenFetched = token.getToken();
        if (isValidFCMToken(tokenFetched)) {
            LOGGER.info("Fetched token ->> " + tokenFetched);
            PushNotificationRequestDTO pushNotification = new PushNotificationRequestDTO();
            pushNotification.setTitle(request.getMessage().getIntent().getChat().getSender().getPerson().getName());
            String content_type = request.getMessage().getIntent().getChat().getContent().getContent_type();
            if (mediaTypeText.equalsIgnoreCase(content_type))
                // pushNotification.setMessage(request.getMessage().getIntent().getChat().getContent().getContent_value());
                pushNotification.setMessage(contentMessage);
            else {
                // String content_url = request.getMessage().getIntent().getChat().getContent().getContent_url();
                // pushNotification.setMessage(content_url);
                pushNotification.setMessage(contentMessage);
            }
            pushNotification.setSenderAbhaAddress(request.getMessage().getIntent().getChat().getSender().getPerson().getId());
            pushNotification.setReceiverAbhaAddress(receiver);
            pushNotification.setProviderUri(request.getContext().getProviderUri());
            pushNotification.setType(ConstantsUtils.CHAT);
            pushNotification.setGender(request.getMessage().getIntent().getChat().getSender().getPerson().getGender());
            pushNotification.setToken(tokenFetched);
            pushNotification.setSharedKey(sharedKey);
            pushNotification.setConsumerUrl(request.getContext().getConsumerUri());
            pushNotification.setContentType(content_type);
            pushNotification.setTransId(request.getContext().getTransactionId());
            pushNotificationService.sendPushNotificationToToken(pushNotification);

            pushNotification = null;
        }
    }

    private void prepareSendCancelNotification(CancelOrderDTO request) throws ExecutionException, InterruptedException {


        LOGGER.info("before serching for token in db" + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));

        String sender = request.getAbhaId();
        String receiver = request.getHealthcareProfessionalId();
        String patientName = request.getPatientName();
        String contentType = null;
        String startDate = request.getServiceFulfillmentStartTime();
        String endDate = request.getServiceFulfillmentEndTime();

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
        LocalDateTime dateTime = LocalDateTime.parse(startDate, formatter);

        DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("dd MMM, yyyy 'at' hh:mm a");

        String newStartDate = dateTime.format(formatter1);
        LOGGER.info("new startdate" + newStartDate);


        contentType = "on_cancel";
        List<UserTokenModel> userTokenByName = getUserTokenByName(receiver);
        LOGGER.info("after serching for token in db" + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));

        for (UserTokenModel token : userTokenByName) {
            if (token.getToken() != null) {
                LOGGER.info("token being processed   " + token.getToken() + "   " + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));

                if (isValidFCMToken(token.getToken())) {
                    PushNotificationRequestDTO pushnot = new PushNotificationRequestDTO();
                    pushnot.setTitle(contentTitleCancel);
                    pushnot.setMessage(contentMessageCancel + " " + newStartDate + " " + contentMessageCancel1 + " " + patientName);
                    pushnot.setSenderAbhaAddress(sender);
                    pushnot.setGender(request.getHealthcareProfessionalGender());
                    pushnot.setReceiverAbhaAddress(receiver);
                    pushnot.setProviderUri("");
                    pushnot.setType("cancel order");
                    pushnot.setToken(token.getToken());
                    pushnot.setSharedKey("");
                    pushnot.setContentType(contentType);
                    pushnot.setConsumerUrl(request.getPatientConsumerUrl());
                    pushnot.setTransId("");
                    pushNotificationService.sendPushNotificationToToken(pushnot);
                    pushnot = null;
                }
            }
        }
        LOGGER.info("finished processing all token   " + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));

    }


    private Boolean isValidFCMToken(String fcmToken) {
        Message message = Message.builder().setToken(fcmToken).build();
        try {
            FirebaseMessaging.getInstance().send(message);
            return true;
        } catch (FirebaseMessagingException fme) {
            LOGGER.error("Firebase token verification exception", fme);
            return false;
        }
    }

    public void sendCancelNotificationToReceiver(CancelOrderDTO request) throws ExecutionException, InterruptedException {
        prepareSendCancelNotification(request);

    }
}