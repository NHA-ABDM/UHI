package in.gov.abdm.uhi.EUABookingService;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Description;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.util.Assert;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import in.gov.abdm.uhi.EUABookingService.controller.ChatController;
import in.gov.abdm.uhi.EUABookingService.dto.MessagesDTO;
import in.gov.abdm.uhi.EUABookingService.dto.RequestTokenDTO;
import in.gov.abdm.uhi.EUABookingService.entity.Messages;
import in.gov.abdm.uhi.EUABookingService.entity.UserToken;
import in.gov.abdm.uhi.EUABookingService.exceptions.UserException;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationResponse;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.FileStorageService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.SaveChatIndbServiceImpl;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import reactor.core.publisher.Mono;

@WebFluxTest(ChatController.class)
class EuaChatServiceControllerTests {

	@Mock
	ChatController chatController;
	
	@MockBean
	SaveChatIndbServiceImpl saveChatService;
	
	@MockBean
	PushNotificationService pushNotification;

	@MockBean
	SimpMessagingTemplate messagingTemplate;
	
	@MockBean
	FileStorageService fileStorageService;

	@Autowired
	WebTestClient webTestClient;
	
	@MockBean
	WebClient webClient;
	
	Response MessageAck;
	
	Request onMessage;
	
	Request Message;
	
	Messages messagedb;
	
	List<Messages> messageList;
	List<MessagesDTO> messageDtoList;
	RequestTokenDTO requestToken;
	UserToken userToken;
	
	ObjectMapper objectMapper;
	
	

	@BeforeEach
	public void setUp() throws JsonProcessingException {
		objectMapper = new ObjectMapper();
		objectMapper.registerModule(new JavaTimeModule());
		MockitoAnnotations.openMocks(this);
			String ack = "{\r\n" + "    \"message\": {\r\n" + "        \"ack\": {\r\n"
				+ "            \"status\": \"ACK\"\r\n" + "        }\r\n" + "    }\r\n" + "}";
	MessageAck = objectMapper.readValue(ack, Response.class);	
		
	
		
		onMessage = objectMapper.readValue("{\"context\":{\"domain\":\"nic2004:85111\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"on_message\",\"timestamp\":\"2023-01-05T10:31:10.609642Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"https://exampleapp.io/\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_id\":\"hspa-nha\",\"provider_uri\":\"https://hspasbx.abdm.gov.in/api/v1\",\"transaction_id\":\"c4409350-8ce1-11ed-895d-1f0feab67fd0\",\"message_id\":\"12511810-8ce4-11ed-9145-3f036e19a38a\"},\"message\":{\"intent\":{\"chat\":{\"sender\":{\"person\":{\"id\":\"ganeshborse@hpr.ndhm\",\"name\":\"Ganesh Vikram Borse\",\"gender\":\"M\",\"image\":\"image2\"}},\"receiver\":{\"person\":{\"id\":\"satish661993@sbx\",\"name\":\"Satish\",\"gender\":\"M\",\"image\":\"image\"}},\"content\":{\"content_id\":\"12511810-8ce4-11ed-9145-3f036e19a38a\",\"content_value\":\"{\\\"type\\\":\\\"CANDIDATE\\\",\\\"data\\\":{\\\"to\\\":\\\"satish661993@sbx\\\",\\\"from\\\":\\\"ganeshborse@hpr.ndhm\\\",\\\"candidate\\\":{\\\"sdpMLineIndex\\\":0,\\\"sdpMid\\\":\\\"0\\\",\\\"candidate\\\":\\\"candidate:508134418 1 udp 41689087 216.39.253.10 32154 typ relay raddr 152.57.104.171 rport 39197 generation 0 ufrag ol21 network-id 6 network-cost 900\\\"},\\\"session_id\\\":\\\"ganeshborse@hpr.ndhm-satish661993@sbx\\\"},\\\"sender\\\":\\\"ganeshborse@hpr.ndhm\\\"}\",\"content_type\":\"video_call_signalling\",\"content_url\":\"\",\"content_fileName\":\"\",\"content_mimeType\":\"\"},\"time\":{\"timestamp\":\"2023-01-05T16:01:10\"}}}}}", Request.class);
		Message = objectMapper.readValue("{\"context\":{\"domain\":\"nic2004:85111\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"message\",\"timestamp\":\"2023-01-05T10:15:50.584777Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"eua-nha\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_uri\":\"https://hspasbx.abdm.gov.in/api/v1\",\"transaction_id\":\"c4409350-8ce1-11ed-895d-1f0feab67fd0\",\"message_id\":\"edf06b80-8ce1-11ed-964f-df7cd47033a6\"},\"message\":{\"intent\":{\"chat\":{\"sender\":{\"person\":{\"id\":\"satish661993@sbx\",\"name\":\"Satish\",\"gender\":\"M\",\"dayOfBirth\":0,\"monthOfBirth\":0,\"yearOfBirth\":0}},\"receiver\":{\"person\":{\"id\":\"ganeshborse@hpr.ndhm\",\"name\":\"Ganesh Vikram Borse\",\"gender\":\"M\",\"image\":\"image\",\"dayOfBirth\":0,\"monthOfBirth\":0,\"yearOfBirth\":0}},\"content\":{\"content_id\":\"edf06b80-8ce1-11ed-964f-df7cd47033a6\",\"content_value\":\"aGV5\",\"content_type\":\"text\",\"content_url\":\"\",\"content_mimeType\":\"text/plain\"},\"time\":{\"timestamp\":\"2023-01-05T15:45:50\"}}}}}", Request.class);
		messagedb = objectMapper.readValue("{\"contentId\":\"f878f0e0-22c5-11ec-ab51-41d31b59e209\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"4321\",\"contentType\":\"text\",\"time\":[2021,10,1,20,13,50],\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"}",Messages.class);
		messageList = objectMapper.readValue("[{\"contentId\":\"f878f0e0-22c5-11ec-ab51-41d31b59e209\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"4321\",\"contentType\":\"text\",\"time\":[2021,10,1,20,13,50],\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"},{\"contentId\":\"fdf275f0-22c5-11ec-9e99-df0cf3ff2374\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"123\",\"contentType\":\"text\",\"time\":[2021,10,1,20,13,50],\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"}]",new TypeReference<List<Messages>>(){});
		messageDtoList = objectMapper.readValue("[{\"contentId\":\"f878f0e0-22c5-11ec-ab51-41d31b59e209\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"4321\",\"contentType\":\"text\",\"time\":\"2021-10-01T20:13:41\",\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"},{\"contentId\":\"fdf275f0-22c5-11ec-9e99-df0cf3ff2374\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"123\",\"contentType\":\"text\",\"time\":\"2021-10-01T20:13:50\",\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"}]",new TypeReference<List<MessagesDTO>>(){});
		userToken=new UserToken();
		userToken.setUserId("nikhil@sbx123");
		userToken.setDeviceId("123");
		userToken.setToken("123");
		userToken.setUserName("nikhil@sbx");	
		requestToken=new RequestTokenDTO();
		requestToken.setUserName("nikhil@sbx");
		requestToken.setDeviceId("123");
		requestToken.setToken("123");
		requestToken.setType("mobile");
	}
	
	

	@Test
	public void contextLoads() {
		//Assertions.assertThat(chatController).isNotNull();
	}

	@Test
	@Description("To test on message call")
	public void givenResponseForOnMessage() throws JsonProcessingException, UserException {		
	
		given(saveChatService.saveChatDataInDb(onMessage)).willReturn(messagedb);		
		given(saveChatService.sendErrorIfProviderUriAndDataIsNull(onMessage,messagedb)).willReturn(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(MessageAck)));		
		given(saveChatService.createAcknowledgementTO()).willReturn(MessageAck);				
		System.out.println("onMessage"+onMessage);		
		Response response = webTestClient.post().uri("/api/v1/bookingService/on_message")
				.body(BodyInserters.fromValue(onMessage)).exchange()
				.expectBody(Response.class).returnResult().getResponseBody();				
		
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("ACK"), "ON MESSAGE");

	}
	
	@Test
	@Description("To test  message call")
	public void givenResponseForMessage() throws JsonProcessingException, UserException {	
		
		given(saveChatService.saveChatDataInDb(Message)).willReturn(messagedb);
		given(saveChatService.checkIfDataIsNullAndCallHspa(Message,messagedb, any(), any())).willReturn(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(MessageAck)));
		given(saveChatService.createAcknowledgementTO()).willReturn(MessageAck);				
		System.out.println("onMessage"+onMessage);		
		Response response = webTestClient.post().uri("/api/v1/bookingService/message")
				.body(BodyInserters.fromValue(Message)).exchange()
				.expectBody(Response.class).returnResult().getResponseBody();					
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("ACK"), "MESSAGE");

	}
	
	@Test
	@Description("Test to get all messages")
	public void givenResponseForGetAllMessages() throws JsonProcessingException, UserException {
		given(saveChatService.getMessageDetails(0,200)).willReturn(messageList);	
		given(saveChatService.convertToMessageDto(messageList)).willReturn(messageDtoList);
		List<MessagesDTO> o = webTestClient.get().uri("/api/v1/bookingService/getMessage")
				.exchange()
				.expectBodyList(MessagesDTO.class).returnResult().getResponseBody();		
		Assert.isTrue(!o.isEmpty(), "NOT Empty");

	}
	
	@Test
	@Description("Test to get all messages between sender and receiver")
	public void givenResponseForGetAllMessagesBetweenTwo() throws JsonProcessingException, UserException {
		given(saveChatService.getMessagesBetweenTwo("sender","receiver",0,200)).willReturn(messageList);	
		given(saveChatService.convertToMessageDto(messageList)).willReturn(messageDtoList);
		List<MessagesDTO> o = webTestClient.get().uri("/api/v1/bookingService/getMessages/sender/receiver")
				.exchange()
				.expectBodyList(MessagesDTO.class).returnResult().getResponseBody();		
		Assert.isTrue(!o.isEmpty(), "NOT Empty");

	}
	
	@Test
	@Description("save token for notification")
	public void givenResponseForSaveToken() throws JsonProcessingException, UserException {
			
		given(saveChatService.saveUserToken(requestToken)).willReturn(userToken);			
		PushNotificationResponse response = webTestClient.post().uri("/api/v1/bookingService/saveToken")
				.body(BodyInserters.fromValue(requestToken)).exchange()
				.expectBody(PushNotificationResponse.class).returnResult().getResponseBody();				
		System.out.println("response to save token"+objectMapper.writeValueAsString(response));	
		Assert.isTrue(response.getMessage().equals("token saved"), "MESSAGE");

	}
	
	@Test
	@Description("Test to get all messages between sender and receiver")
	public void givenResponseForGetUserToken() throws JsonProcessingException, UserException {
		
		List<UserToken> ut= new ArrayList<>();
		ut.add(userToken);		
		given(saveChatService.getAllUserToken()).willReturn(ut);	
		List<UserToken> o = webTestClient.get().uri("/api/v1/bookingService/getTokenUsers")
				.exchange()
				.expectBodyList(UserToken.class).returnResult().getResponseBody();		
		Assert.isTrue(!o.isEmpty(), "NOT Empty");

	}
	
	
	@Test
	@Description("save token for notification")
	public void givenResponseForDeleteToken() throws JsonProcessingException, UserException {
				
		given(saveChatService.deleteToken(requestToken)).willReturn(new ResponseEntity<>(new PushNotificationResponse(HttpStatus.OK.value(), "token deleted"), HttpStatus.OK));			
		PushNotificationResponse response = webTestClient.post().uri("/api/v1/bookingService/logout")
				.body(BodyInserters.fromValue(requestToken)).exchange()
				.expectBody(PushNotificationResponse.class).returnResult().getResponseBody();				
		System.out.println("Response to delete token"+objectMapper.writeValueAsString(response));	
		Assert.isTrue(response.getMessage().equals("token deleted"), "MESSAGE");

	}
	
	
	
	
}
