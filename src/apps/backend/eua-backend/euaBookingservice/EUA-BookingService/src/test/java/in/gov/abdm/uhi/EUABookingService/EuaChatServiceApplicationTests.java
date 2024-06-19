package in.gov.abdm.uhi.EUABookingService;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.RETURNS_MOCKS;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.junit.jupiter.MockitoExtension;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.util.Assert;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import in.gov.abdm.uhi.EUABookingService.dto.MessagesDTO;
import in.gov.abdm.uhi.EUABookingService.dto.RequestTokenDTO;
import in.gov.abdm.uhi.EUABookingService.entity.ChatUser;
import in.gov.abdm.uhi.EUABookingService.entity.Messages;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.entity.UserToken;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationResponse;
import in.gov.abdm.uhi.EUABookingService.repository.ChatUserReposotory;
import in.gov.abdm.uhi.EUABookingService.repository.MessagesRepository;
import in.gov.abdm.uhi.EUABookingService.repository.OrderRepository;
import in.gov.abdm.uhi.EUABookingService.repository.UserTokenRepository;
import in.gov.abdm.uhi.EUABookingService.service.SaveDataDbService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.SaveChatIndbServiceImpl;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.SaveInDbServiceImpl;
import in.gov.abdm.uhi.common.dto.Person;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;

@ExtendWith(MockitoExtension.class)
class EuaChatServiceApplicationTests {
	
	@Mock
	MessagesRepository messagesRepo;
	
	@Mock
	UserTokenRepository userTokenRepo;

	
	@InjectMocks	
	SaveChatIndbServiceImpl saveChatInDbService;
	
		
	@Autowired
    private ObjectMapper objectMapper;
	
	
	
	Messages messages;
	
	@Mock
	ModelMapper modelMapper;	
	
	@Mock
	ChatUserReposotory chatUserRepo;
	
	List<Messages> messagesList;	
	MessagesDTO messagesDto;	
	List<MessagesDTO> messagesListDto;

	@Autowired
	WebTestClient webTestClient;
	
	Response MessageAck;	
	Request onMessage;	
	Request Message;
	RequestTokenDTO requestToken;
	UserToken userToken;
	Person person;
	
	ChatUser chatUser;
	
	@BeforeEach
	public void setUp() throws JsonProcessingException {
		objectMapper = new ObjectMapper();
		objectMapper.registerModule(new JavaTimeModule());
		MockitoAnnotations.openMocks(this);
		String ack = "{\r\n" + "    \"message\": {\r\n" + "        \"ack\": {\r\n"
				+ "            \"status\": \"ACK\"\r\n" + "        }\r\n" + "    }\r\n" + "}";
		onMessage = objectMapper.readValue("{\"context\":{\"domain\":\"nic2004:85111\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"on_message\",\"timestamp\":\"2023-01-05T10:31:10.609642Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"https://exampleapp.io/\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_id\":\"hspa-nha\",\"provider_uri\":\"https://hspasbx.abdm.gov.in/api/v1\",\"transaction_id\":\"c4409350-8ce1-11ed-895d-1f0feab67fd0\",\"message_id\":\"12511810-8ce4-11ed-9145-3f036e19a38a\"},\"message\":{\"intent\":{\"chat\":{\"sender\":{\"person\":{\"id\":\"ganeshborse@hpr.ndhm\",\"name\":\"Ganesh Vikram Borse\",\"gender\":\"M\",\"image\":\"image2\"}},\"receiver\":{\"person\":{\"id\":\"satish661993@sbx\",\"name\":\"Satish\",\"gender\":\"M\",\"image\":\"image\"}},\"content\":{\"content_id\":\"12511810-8ce4-11ed-9145-3f036e19a38a\",\"content_value\":\"{\\\"type\\\":\\\"CANDIDATE\\\",\\\"data\\\":{\\\"to\\\":\\\"satish661993@sbx\\\",\\\"from\\\":\\\"ganeshborse@hpr.ndhm\\\",\\\"candidate\\\":{\\\"sdpMLineIndex\\\":0,\\\"sdpMid\\\":\\\"0\\\",\\\"candidate\\\":\\\"candidate:508134418 1 udp 41689087 216.39.253.10 32154 typ relay raddr 152.57.104.171 rport 39197 generation 0 ufrag ol21 network-id 6 network-cost 900\\\"},\\\"session_id\\\":\\\"ganeshborse@hpr.ndhm-satish661993@sbx\\\"},\\\"sender\\\":\\\"ganeshborse@hpr.ndhm\\\"}\",\"content_type\":\"video_call_signalling\",\"content_url\":\"\",\"content_fileName\":\"\",\"content_mimeType\":\"\"},\"time\":{\"timestamp\":\"2023-01-05T16:01:10\"}}}}}", Request.class);
		Message = objectMapper.readValue("{\"context\":{\"domain\":\"nic2004:85111\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"message\",\"timestamp\":\"2023-01-05T10:15:50.584777Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"eua-nha\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_uri\":\"https://hspasbx.abdm.gov.in/api/v1\",\"transaction_id\":\"c4409350-8ce1-11ed-895d-1f0feab67fd0\",\"message_id\":\"edf06b80-8ce1-11ed-964f-df7cd47033a6\"},\"message\":{\"intent\":{\"chat\":{\"sender\":{\"person\":{\"id\":\"satish661993@sbx\",\"name\":\"Satish\",\"gender\":\"M\",\"dayOfBirth\":0,\"monthOfBirth\":0,\"yearOfBirth\":0}},\"receiver\":{\"person\":{\"id\":\"ganeshborse@hpr.ndhm\",\"name\":\"Ganesh Vikram Borse\",\"gender\":\"M\",\"image\":\"image\",\"dayOfBirth\":0,\"monthOfBirth\":0,\"yearOfBirth\":0}},\"content\":{\"content_id\":\"edf06b80-8ce1-11ed-964f-df7cd47033a6\",\"content_value\":\"aGV5\",\"content_type\":\"text\",\"content_url\":\"\",\"content_mimeType\":\"text/plain\"},\"time\":{\"timestamp\":\"2023-01-05T15:45:50\"}}}}}", Request.class);
		messages = objectMapper.readValue("{\"contentId\":\"f878f0e0-22c5-11ec-ab51-41d31b59e209\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"4321\",\"contentType\":\"text\",\"time\":[2021,10,1,20,13,50],\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"}",Messages.class);
		messagesList = objectMapper.readValue("[{\"contentId\":\"f878f0e0-22c5-11ec-ab51-41d31b59e209\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"4321\",\"contentType\":\"text\",\"time\":[2021,10,1,20,13,50],\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"},{\"contentId\":\"fdf275f0-22c5-11ec-9e99-df0cf3ff2374\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"123\",\"contentType\":\"text\",\"time\":[2021,10,1,20,13,50],\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"}]",new TypeReference<List<Messages>>(){});
		messagesListDto = objectMapper.readValue("[{\"contentId\":\"f878f0e0-22c5-11ec-ab51-41d31b59e209\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"4321\",\"contentType\":\"text\",\"time\":\"2021-10-01T20:13:41\",\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"},{\"contentId\":\"fdf275f0-22c5-11ec-9e99-df0cf3ff2374\",\"sender\":\"amodjoshi@sbx\",\"receiver\":\"ganeshborse@hpr.ndhm\",\"contentValue\":\"123\",\"contentType\":\"text\",\"time\":\"2021-10-01T20:13:50\",\"consumerUrl\":\"http://100.65.158.41:8901/api/v1/euaService\",\"providerUrl\":\"http://100.96.9.171:8084/api/v1\"}]",new TypeReference<List<MessagesDTO>>(){});
		
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
		
		
		chatUser=new ChatUser();
		chatUser.setUserId("userid");
		chatUser.setUserName("username");
		
		
		 person=new Person();
		 person.setId("123");
		 person.setCred("cred");
		 person.setName("name");
		 person.setImage("image");
	
	}
	@Test
	void contextLoads() {
	}	
	
	   @Test
	    public void testGetAllUserToken() throws Exception {	  					
			List<UserToken> ut= new ArrayList<>();
			ut.add(userToken);
	        when(userTokenRepo.findAll())
	                .thenReturn(ut);	        	           
	        assertEquals(1, saveChatInDbService.getAllUserToken().size());
	    }
	   
	   
	   @Test
	    public void testGetUserTokenByName() throws Exception {		 			
			List<UserToken> ut= new ArrayList<>();
			ut.add(userToken);
	        when(userTokenRepo.findByUserName("nikhil@sbx"))
	                .thenReturn(ut);
	        assertEquals(1, saveChatInDbService.getUserTokenByName("nikhil@sbx").size());
	    }	   
	   
	   @Test
	    public void testToconcatReceiverSender() throws Exception { 	
				
				  Assert.isTrue(saveChatInDbService.concatReceiverSender("Sender","Receiver")!=null,"NOTNULL");
	    }	   
	   
	   @Test
	    public void testsendErrorIfProviderUriAndDataIsNull() throws Exception { 	
				
				  Assert.isTrue(saveChatInDbService.sendErrorIfProviderUriAndDataIsNull(Message,messages)!=null,"NOTNULL");
	    }	
	   
	   @Test
	    public void testToSaveUserTokenByName() throws Exception { 	
			 when(userTokenRepo.save(any()))
            .thenReturn(userToken);				
				  Assert.isTrue(saveChatInDbService.saveUserToken(requestToken)!=null,"NOTNULL");
	    }	
	   
	   
	   @Test
	    public void testsaveSenderAndReceiver() throws Exception { 		
			 when(chatUserRepo.saveAll(any()))
            .thenReturn(List.of(chatUser));	
            when( messagesRepo.save(any()))
            .thenReturn(messages);				 
				  Assert.isTrue(saveChatInDbService.saveChatDataInDb(Message)!=null,"NOTNULL");
	    }	
	   
	   @Test
	    public void testToConvertMessagesToDto() throws Exception {			 		   		   
		   Assert.isTrue( saveChatInDbService.convertToMessageDto(messagesList)==null,"IS NULL");
	    }	   
	   
	   @Test
	    public void testToGetErrorMessage() throws Exception {			       
		   Assert.isTrue(saveChatInDbService.getErrorMessage("ERROR").get(0).getError().getErrorString().equals("ERROR"), "ERROR");
	    }
	   
	   
	   
	   @Test
	    public void testToGetAck() throws Exception {		   
	       
		   Assert.isTrue(saveChatInDbService.createAcknowledgementTO().getMessage().getAck().getStatus().equals("ACK"), "ACK");
	    }
	   
	   @Test
	    public void testToGetNack() throws Exception {		   
	       
		   Assert.isTrue(saveChatInDbService.createNacknowledgementTO("NACK").getMessage().getAck().getStatus().equals("NACK"), "NACK");
	    }
	   
	   @Test
	    public void testToCheckNull() throws Exception {		   
	       
		   Assert.isTrue(saveChatInDbService.applyDataValidation(Message,messages), "Test Null");
	    }
	   
	   @Test
	    public void testToCheckSenderReceiver() throws Exception {		   
	       
		   Assert.isTrue(saveChatInDbService.concatReceiverSender("Sender","Receiver").equals("Sender|Receiver"), "Test Null");
	    }

}
