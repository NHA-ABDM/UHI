package in.gov.abdm.uhi.EUABookingService.service;

import java.util.List;
import java.util.concurrent.ExecutionException;

import org.springframework.http.ResponseEntity;

import in.gov.abdm.uhi.EUABookingService.dto.RequestSharedKeyDTO;
import in.gov.abdm.uhi.EUABookingService.dto.RequestTokenDTO;
import in.gov.abdm.uhi.EUABookingService.entity.ChatUser;
import in.gov.abdm.uhi.EUABookingService.entity.Messages;
import in.gov.abdm.uhi.EUABookingService.entity.SharedKey;
import in.gov.abdm.uhi.EUABookingService.entity.UserToken;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationResponse;
import in.gov.abdm.uhi.common.dto.Request;

public interface ChatDataDbService {
	
Messages saveChatDataInDb(Request request) ;
List<Messages> getMessageDetails(Integer pageNumber,Integer pageSize);
List<ChatUser> getUserdetails(String userId);
List<ChatUser> getAllUsers();

List<Messages> getMessagesBetweenTwo(String sender,String receiver,Integer pageNumber,Integer pageSize);
UserToken saveUserToken(RequestTokenDTO requesttoken);
List<UserToken> getAllUserToken();
List<UserToken> getUserTokenByName(String userName);
String concatReceiverSender(String receiver,String sender);
void sendNotificationToreceiver(Request request)throws InterruptedException, ExecutionException ;
ResponseEntity<PushNotificationResponse> deleteToken(RequestTokenDTO tokenDTO);
SharedKey saveSharedKey(RequestSharedKeyDTO request);
List<SharedKey> getKeyDetails(String userName);

}
