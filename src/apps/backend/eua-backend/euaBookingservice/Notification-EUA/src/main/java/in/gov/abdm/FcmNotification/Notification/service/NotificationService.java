package in.gov.abdm.FcmNotification.Notification.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.ExecutionException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;

import in.gov.abdm.FcmNotification.Notification.dto.CancelOrderDTO;
import in.gov.abdm.FcmNotification.Notification.dto.PushNotificationRequestDTO;
import in.gov.abdm.FcmNotification.Notification.model.SharedKey;
import in.gov.abdm.FcmNotification.Notification.model.UserToken;
import in.gov.abdm.FcmNotification.Notification.repo.SharedKeyRepository;
import in.gov.abdm.FcmNotification.Notification.repo.UserTokenRepository;
import in.gov.abdm.FcmNotification.Notification.utils.ConstantsUtils;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;

@Service
public class NotificationService {

    private final Logger logger = LogManager.getLogger(NotificationService.class);
    static final String dateFormat="yyyy-MM-dd HH:mm:ss";

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
    
    final UserTokenRepository userTokenRepository;
    final SharedKeyRepository sharedKeyRepository;
    final PushNotificationService pushNotificationService;

    public NotificationService(UserTokenRepository userTokenRepository, SharedKeyRepository sharedKeyRepository, PushNotificationService pushNotificationService) {
        this.userTokenRepository = userTokenRepository;
        this.sharedKeyRepository = sharedKeyRepository;
        this.pushNotificationService = pushNotificationService;
    }

    public void sendNotificationToReceiver(Request request) throws ExecutionException, InterruptedException {
        
    	prepareSendNotification(request);
    }

    public List<UserToken> getUserTokenByName(String userName) {
        return userTokenRepository.findByUserName(userName);
    }



    public List<SharedKey> getSharedKeyDetails(String userName) {
        return sharedKeyRepository.findByUserName(userName);
    }

    private void prepareSendNotification(Request request) throws ExecutionException, InterruptedException {		

    	logger.info("before serching for token in db"+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
    	
    	String receiver=request.getMessage().getIntent().getChat().getReceiver().getPerson().getId();
		String sender =request.getMessage().getIntent().getChat().getSender().getPerson().getId();
		String contentType=request.getMessage().getIntent().getChat().getContent().getContent_type();
		List<UserToken> userTokenByName = getUserTokenByName(receiver);
		logger.info("after serching for token in db"+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
		
		List<SharedKey> lsk=getSharedKeyDetails(sender);
		logger.info("after serching for shared key in db"+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
		
		String sharedKey="";
		if(!lsk.isEmpty())
		{
			sharedKey=lsk.get(0).getPublicKey();
		}
	for(UserToken token:userTokenByName){		
		if(token.getToken()!=null)
		{		
			logger.info("token being processed   "+token.getToken()+"   "+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
			
			if(isValidFCMToken(token.getToken()))
				{				
					PushNotificationRequestDTO pushnot=new PushNotificationRequestDTO();
					pushnot.setTitle(request.getMessage().getIntent().getChat().getSender().getPerson().getName());
					if(contentType.equalsIgnoreCase("media"))											
						pushnot.setMessage(contentMessage);					
					else {						
						    pushnot.setMessage(contentMessage);
						 }
					pushnot.setSenderAbhaAddress(sender);
					pushnot.setGender(request.getMessage().getIntent().getChat().getSender().getPerson().getGender());
					pushnot.setReceiverAbhaAddress(receiver);
					pushnot.setProviderUri(request.getContext().getProviderUri());
					pushnot.setType(ConstantsUtils.CHAT);
					pushnot.setToken(token.getToken());			
					pushnot.setSharedKey(sharedKey);
					pushnot.setTransId(request.getContext().getTransactionId());
					pushnot.setContentType(contentType);
					pushNotificationService.sendPushNotificationToToken(pushnot);
					pushnot=null;
				}
		}
		}	
	logger.info("finished processing all token   "+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
	}
    
    private void prepareSendCancelNotification(CancelOrderDTO request) throws ExecutionException, InterruptedException {		
    	
    	logger.info("before serching for token in db"+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
    	
    	String receiver=request.getAbhaId();
		String sender =request.getHealthcareProfessionalId();
		String contentType=null;		
		 contentType="on_cancel";	
		String startDate=request.getServiceFulfillmentStartTime();
		
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
		LocalDateTime dateTime = LocalDateTime.parse(startDate, formatter);
		
		DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("dd MMM, yyyy 'at' hh:mm a");

        String newStartDate = dateTime.format(formatter1);
        logger.info("new startdate"+newStartDate);
		
		String doctorName=request.getHealthcareProfessionalName();
		if(doctorName.contains("-"))
		{
			doctorName=doctorName.substring(doctorName.lastIndexOf("-") + 1);
		}
		logger.info("Doctors name       "+doctorName);
		
		
		
		List<UserToken> userTokenByName = getUserTokenByName(receiver);
		logger.info("after serching for token in db"+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));

		for(UserToken token:userTokenByName){		
		if(token.getToken()!=null)
		{		
			logger.info("token being processed   "+token.getToken()+"   "+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
			
			if(isValidFCMToken(token.getToken()))
				{				
					PushNotificationRequestDTO pushnot=new PushNotificationRequestDTO();
					pushnot.setTitle(contentTitleCancel);

					pushnot.setMessage(contentMessageCancel+" "+newStartDate+" "+contentMessageCancel1+doctorName);
					
					pushnot.setSenderAbhaAddress(sender);
					pushnot.setGender(request.getHealthcareProfessionalGender());
					pushnot.setReceiverAbhaAddress(receiver);
					pushnot.setProviderUri("");
					pushnot.setType("cancel order");
					pushnot.setToken(token.getToken());			
					pushnot.setSharedKey("");
					pushnot.setTransId("");
					
					pushnot.setContentType(contentType);
					pushNotificationService.sendPushNotificationToToken(pushnot);
					pushnot=null;
				}
		}
		}	
		logger.info("finished processing all token   "+DateTimeFormatter.ofPattern(dateFormat).format(LocalDateTime.now()));
	
	}

    private boolean isValidFCMToken(String fcmToken) {
        Message message = Message.builder().setToken(fcmToken).build();
        try {
            FirebaseMessaging.getInstance().send(message);
            return true;
        } catch (FirebaseMessagingException fme) {
        	logger.error("Firebase token verification exception", fme);
            return false;
        }
    }

    private static Response generateAck(ObjectMapper mapper) {

        String jsonString;
        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("ACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new in.gov.abdm.uhi.common.dto.Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    private static Response generateNack(ObjectMapper mapper, Exception js) {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new Error();
        err.setMessage(js.getMessage());
        err.setType("Search");
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

	public void sendCancelNotificationToReceiver(CancelOrderDTO request) throws ExecutionException, InterruptedException{
		prepareSendCancelNotification(request);
		
	}


}
