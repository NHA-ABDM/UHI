package in.gov.abdm.uhi.EUABookingService.controller;

import java.util.List;

import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;
import in.gov.abdm.uhi.EUABookingService.dto.MessagesDTO;
import in.gov.abdm.uhi.EUABookingService.dto.RequestTokenDTO;
import in.gov.abdm.uhi.EUABookingService.entity.ChatUser;
import in.gov.abdm.uhi.EUABookingService.entity.Messages;
import in.gov.abdm.uhi.EUABookingService.entity.UserToken;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationRequest;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationResponse;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationService;
import in.gov.abdm.uhi.EUABookingService.service.ChatDataDbService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.SaveChatIndbServiceImpl;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping(value = "/api/v1/bookingService")
@Api(tags = "Chat Service", value = "Chatservice")
public class ChatController {
	Logger LOGGER = LoggerFactory.getLogger(ChatController.class);

	@Autowired
	ChatDataDbService chatdatadb;

	@Autowired
	private SimpMessagingTemplate messagingTemplate;

	@Autowired
	WebClient webclient;

	@Autowired
	SaveChatIndbServiceImpl saveChatService;

	@Autowired
	 private PushNotificationService pushNotificationService;
	    
	    public ChatController(PushNotificationService pushNotificationService) {
	        this.pushNotificationService = pushNotificationService;
	    }
	
	@ApiOperation(value ="Message reponse from HSPA", notes="HSPA will hit this api as a response to EUA and save in database")
	@PostMapping(path = "/on_message")
	public ResponseEntity<Response> saveChatForMessage(@RequestBody @Valid Request request) {

		try {
			LOGGER.info(request.getContext().getMessageId() + "Received request inside on_message " + request);

			String receiver = request.getMessage().getIntent().getChat().getReceiver().getPerson().getCred();
			String sender = request.getMessage().getIntent().getChat().getSender().getPerson().getCred();

			String concatReceiverSender = chatdatadb.concatReceiverSender(receiver, sender);			
			messagingTemplate.convertAndSendToUser(concatReceiverSender, "/queue/specific-user", request);
			Messages saveDataInDb = chatdatadb.saveChatDataInDb(request);
			
			chatdatadb.sendNotificationToreceiver(request);
			
			LOGGER.info("after save to db" + saveDataInDb);
			return saveChatService.sendErrorIfProviderUriAndDataIsNull(request, saveDataInDb);
		} catch (NullPointerException e) {
			LOGGER.error(request.getContext().getMessageId() + "  Null pointer Exception  " + e);

		} catch (Exception e) {
			LOGGER.error(request.getContext().getMessageId() + "  Something went wrong  " + e);

		}
		return ResponseEntity.status(HttpStatus.BAD_REQUEST)
				.body(saveChatService.createNacknowledgementTO(null));
	}

	@ApiOperation(value ="Message reponse from EUA", notes="EUA will hit this api as a request to HSPA and save in database")
	@PostMapping(path = "/message")
	public ResponseEntity<Mono<Response>> saveChatForOnMessage(@RequestBody @Valid Request request) {

		try {
			LOGGER.error(request.getContext().getMessageId() + "Received request inside message " + request);
			Messages saveDataInDb = chatdatadb.saveChatDataInDb(request);
			return saveChatService.checkIfDataIsNullAndCallHspa(request, saveDataInDb);

		} catch (NullPointerException e) {
			LOGGER.error(request.getContext().getMessageId() + "  Null pointer Exception  " + e);

		} catch (Exception e) {
			LOGGER.error(request.getContext().getMessageId() + "  Something went wrong  " + e);

		}
		Response createNacknowledgementTO = saveChatService.createNacknowledgementTO(null);
		return ResponseEntity.status(HttpStatus.OK).body(Mono.just(createNacknowledgementTO));
	}

	@ApiOperation(value = "Get all messages",notes="This endpoint will give all messages from database")
	@GetMapping(path = "/getMessage")
	public ResponseEntity<List<MessagesDTO>> getMessage(
			@RequestParam(value = "pageNumber", defaultValue = "0", required = false) Integer pageNumber,
			@RequestParam(value = "pageSize", defaultValue = "200", required = false) Integer pageSize) {
		LOGGER.info("inside Get all Messages");
		List<Messages> getMessageDetails = chatdatadb.getMessageDetails(pageNumber, pageSize);
		return new ResponseEntity<>(saveChatService.convertToMessageDto(getMessageDetails), HttpStatus.OK);
	}	
	
	@ApiOperation(value = "Get users by userid", notes="This endpoint will give users by userid ")
	@GetMapping(path = "/getUser/{userid}")
	public ResponseEntity<List<ChatUser>> getUserById(@PathVariable("userid") String userId) {
		LOGGER.info("inside Get user by id");
		List<ChatUser> getUserDetails = chatdatadb.getUserdetails(userId);
		return new ResponseEntity<>(getUserDetails, HttpStatus.OK);
	}
	
	@ApiOperation(value = "Get all users ", notes="This endpoint will give all available users")
	@GetMapping(path = "/getUser")
	public ResponseEntity<List<ChatUser>> getAllUsers() {
		LOGGER.info("inside Get all Users");
		List<ChatUser> getUserDetails = chatdatadb.getAllUsers();
		return new ResponseEntity<>(getUserDetails, HttpStatus.OK);
	}

	@ApiResponses(
            value = { @ApiResponse(code = 200, message = "Success", response = MessagesDTO.class)})
    @ApiOperation(value ="Find message b/w sender and receiver", notes="This endpoint will give conversation  b/w sender and receiver")
	@GetMapping(path = "/getMessages/{sender}/{receiver}")
	public ResponseEntity<List<MessagesDTO>> getMessagesBetweenTwo(@PathVariable("sender") String sender,
			@PathVariable("receiver") String receiver,
			@RequestParam(value = "pageNumber", defaultValue = "0", required = false) Integer pageNumber,
			@RequestParam(value = "pageSize", defaultValue = "200", required = false) Integer pageSize) {
		try {
			LOGGER.info("inside Get message by sender receiver");
			List<Messages> getMessageDetails = chatdatadb.getMessagesBetweenTwo(sender, receiver, pageNumber, pageSize);
			return new ResponseEntity<>(saveChatService.convertToMessageDto(getMessageDetails), HttpStatus.OK);
		} catch (Exception e) {
			LOGGER.info("Requester::error::sender ::" + sender);
			LOGGER.info("Requester::error::receiver ::" + receiver);
			LOGGER.error(e.getMessage());
			List<MessagesDTO> messagesDTOS = saveChatService.getErrorMessage(e.getMessage());
			return new ResponseEntity<>(messagesDTOS, HttpStatus.INTERNAL_SERVER_ERROR);

		}
	}
	
	@ApiOperation(value = "Send notification to HSPA ", notes="this endpoint will send notification to HSPA based on given token ")
	@PostMapping("/notification/token")
    public ResponseEntity<PushNotificationResponse> sendTokenNotification(@RequestBody PushNotificationRequest request) {
        pushNotificationService.sendPushNotificationToToken(request);
        System.out.println("send notification");
        return new ResponseEntity<>(new PushNotificationResponse(HttpStatus.OK.value(), "Notification has been sent."), HttpStatus.OK);
    }
	
	@ApiOperation(value = "Save user token in database ", notes="app will hit this endpoint to save user token ")
	@PostMapping("/saveToken")
    public ResponseEntity<PushNotificationResponse> saveToken(@RequestBody RequestTokenDTO request) {
		UserToken saveUserToken = chatdatadb.saveUserToken(request);
        if(null!=saveUserToken)
        {
        return new ResponseEntity<>(new PushNotificationResponse(HttpStatus.OK.value(), "token saved"), HttpStatus.OK);
        }
        else
        {
        	return new ResponseEntity<>(new PushNotificationResponse(HttpStatus.BAD_REQUEST.value(), "token not saved"), HttpStatus.OK);
        }       
    }
	
	
	@ApiOperation(value = "Get token assigned to users", notes="Get details of all token assigned to users")
	@GetMapping(path = "/getTokenUsers")
	public ResponseEntity<List<UserToken>> getAllTokenUsers() {
		LOGGER.info("inside Get all Token Users");
	List<UserToken> allUserToken = chatdatadb.getAllUserToken();
		return new ResponseEntity<>(allUserToken, HttpStatus.OK);
	}
	
	
	

}
