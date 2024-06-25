package in.gov.abdm.uhi.EUABookingService.controller;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.tomcat.util.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;
import in.gov.abdm.uhi.EUABookingService.dto.ErrorResponseDTO;
import in.gov.abdm.uhi.EUABookingService.dto.MessagesDTO;
import in.gov.abdm.uhi.EUABookingService.dto.RequestSharedKeyDTO;
import in.gov.abdm.uhi.EUABookingService.dto.RequestTokenDTO;
import in.gov.abdm.uhi.EUABookingService.dto.UploadFileResponse;
import in.gov.abdm.uhi.EUABookingService.entity.ChatUser;
import in.gov.abdm.uhi.EUABookingService.entity.Messages;
import in.gov.abdm.uhi.EUABookingService.entity.SharedKey;
import in.gov.abdm.uhi.EUABookingService.entity.UserToken;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationRequest;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationResponse;
import in.gov.abdm.uhi.EUABookingService.notification.PushNotificationService;
import in.gov.abdm.uhi.EUABookingService.service.ChatDataDbService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.FileStorageService;
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
	Logger logger = LogManager.getLogger(ChatController.class);

	@Value("${spring.file.upload-dir}")
    private String uploadDir;
	
	@Value("${spring.notificationService.baseUrl}")
	private String notificationServiceBaseUrl;
	
	@Value("${spring.base.url}")
	private String baseUrl;
//	@Autowired
//	ChatDataDbService chatdatadb;

	@Autowired
	private SimpMessagingTemplate messagingTemplate;

	@Autowired
	WebClient webclient;

	@Autowired
	SaveChatIndbServiceImpl saveChatService;
	
	@Autowired
    FileStorageService fileStorageService;

	@Autowired
	ObjectMapper objectMapper;
	

	@Autowired
	 private PushNotificationService pushNotificationService;
	    
	    public ChatController(PushNotificationService pushNotificationService) {
	        this.pushNotificationService = pushNotificationService;
	    }
	
	@ApiOperation(value ="Message reponse from HSPA", notes="HSPA will hit this api as a response to EUA and save in database")
	@PostMapping(path = "/on_message")
	public ResponseEntity<Mono<Response>> saveChatForMessage(@RequestBody @Valid Request request) {
		try {
			logger.info(request.getContext().getMessageId() + "Received request inside on_message " + objectMapper.writeValueAsString(request));

			String receiver = request.getMessage().getIntent().getChat().getReceiver().getPerson().getId();
			String sender = request.getMessage().getIntent().getChat().getSender().getPerson().getId();
			String fileDownloadUri="";
			String concatReceiverSender = request.getContext().getTransactionId();
			String contentType= request.getMessage().getIntent().getChat().getContent().getContent_type();
			if(contentType.equalsIgnoreCase(ConstantsUtils.MEDIA))
			{
				String messageid=request.getContext().getMessageId();
				String contentFileName = messageid+request.getMessage().getIntent().getChat().getContent().getContent_filename();
				
				Files.createDirectories(Paths.get(uploadDir).toAbsolutePath().normalize());
				try (OutputStream stream = new FileOutputStream(uploadDir+"/"+ contentFileName)) {
				   String contentValue = request.getMessage().getIntent().getChat().getContent().getContent_value();
				   byte[] fileBytes = Base64.decodeBase64(contentValue);
				   stream.write(fileBytes);
				}
		         fileDownloadUri = baseUrl+ConstantsUtils.DOWNLOADFILE+contentFileName;
				request.getMessage().getIntent().getChat().getContent().setContent_value("");
				request.getMessage().getIntent().getChat().getContent().setContent_url(fileDownloadUri);
			}
			messagingTemplate.convertAndSendToUser(concatReceiverSender, "/queue/specific-user", request);
			if((contentType.equalsIgnoreCase(ConstantsUtils.MEDIA))||(contentType.equalsIgnoreCase(ConstantsUtils.TEXT)))
					{
			
			Messages saveDataInDb = saveChatService.saveChatDataInDb(request);
					
						
			webclient.post().uri(notificationServiceBaseUrl+"/sendNotification")
		      .body(BodyInserters.fromValue(request))
		      .retrieve()
		      .onStatus(HttpStatus::is4xxClientError,
		            response -> response.bodyToMono(String.class).map(Exception::new))
		      .onStatus(HttpStatus::is5xxServerError,
		            response -> response.bodyToMono(String.class).map(Exception::new))
		      .toEntity(String.class)
		      .doOnError(throwable -> {
		    	  logger.error("Error sending notification---"+throwable.getMessage());
		      }).subscribe(res ->logger.info("Sent notification---"+res.getBody()));
			
			logger.info("after save to db" + saveDataInDb);
			return saveChatService.sendErrorIfProviderUriAndDataIsNull(request, saveDataInDb);
					}
			
			return ResponseEntity.status(HttpStatus.OK)
					.body(Mono.just(saveChatService.createAcknowledgementTO()));
		} catch (NullPointerException  e) {
			logger.error(request.getContext().getMessageId() + "  Null pointer Exception  " + e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Mono.just(saveChatService.createNacknowledgementTO(e.getMessage())));

		} catch (Exception e) {
			logger.error(request.getContext().getMessageId() + "  Something went wrong  " + e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Mono.just(saveChatService.createNacknowledgementTO(e.getMessage())));
		}
		
		
	}

	@ApiOperation(value ="Message reponse from EUA", notes="EUA will hit this api as a request to HSPA and save in database")
	@PostMapping(path = "/message",consumes = {MediaType.APPLICATION_JSON_VALUE,MediaType.MULTIPART_FORM_DATA_VALUE})
	public ResponseEntity<Mono<Response>> saveChatForOnMessage(@RequestBody @Valid String req, @RequestHeader Map<String, String> headers) {
		 String fileDownloadUri="";
			Request request;
			
			try {
				request = objectMapper.readValue(req,Request.class);
				String contentType= request.getMessage().getIntent().getChat().getContent().getContent_type();
				try {
					Messages saveDataInDb=new Messages();
					logger.error(request.getContext().getMessageId() + "Received request inside message " + req);
	
					if(contentType.equalsIgnoreCase(ConstantsUtils.MEDIA))
					{
						String messageid=request.getContext().getMessageId();
						String content_fileName = messageid+request.getMessage().getIntent().getChat().getContent().getContent_filename();
						
						Files.createDirectories(Paths.get(uploadDir).toAbsolutePath().normalize());
						try (OutputStream stream = new FileOutputStream(uploadDir+"/"+ content_fileName)) {
						   String content_value = request.getMessage().getIntent().getChat().getContent().getContent_value();
						   byte[] fileBytes = Base64.decodeBase64(content_value);
						   stream.write(fileBytes);
						}
				         fileDownloadUri = baseUrl+"/downloadFile/"+content_fileName;
						request.getMessage().getIntent().getChat().getContent().setContent_url(fileDownloadUri);
				   
					}
					if((contentType.equalsIgnoreCase(ConstantsUtils.MEDIA))||(contentType.equalsIgnoreCase(ConstantsUtils.TEXT)))
					{					
					 saveDataInDb = saveChatService.saveChatDataInDb(request);						
					}
					return saveChatService.checkIfDataIsNullAndCallHspa(request, saveDataInDb, req,headers);
				} catch (NullPointerException e) {
					logger.error(request.getContext().getMessageId() + "  Null pointer Exception  " + e);					
					Response createNacknowledgementTO = saveChatService.createNacknowledgementTO(e.getMessage());
					return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(createNacknowledgementTO));

				} catch (Exception e) {
					logger.error(request.getContext().getMessageId() + "  Something went wrong  " + e);
					Response createNacknowledgementTO = saveChatService.createNacknowledgementTO(e.getMessage());
					return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(createNacknowledgementTO));
				}
			} catch (JsonProcessingException e1) {
				logger.error("  JsonProcessingException  " + e1);
				e1.printStackTrace();
			}
			
			Response createNacknowledgementTO = saveChatService.createNacknowledgementTO(null);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(createNacknowledgementTO));
		}

	@ApiOperation(value = "Get all messages",notes="This endpoint will give all messages from database")
	@GetMapping(path = "/getMessage")
	public ResponseEntity<List<MessagesDTO>> getMessage(
			@RequestParam(value = "pageNumber", defaultValue = "0", required = false) Integer pageNumber,
			@RequestParam(value = "pageSize", defaultValue = "200", required = false) Integer pageSize) throws JsonProcessingException {
		logger.info("inside Get all Messages");
		List<Messages> getMessageDetails = saveChatService.getMessageDetails(pageNumber, pageSize);
		return new ResponseEntity<>(saveChatService.convertToMessageDto(getMessageDetails), HttpStatus.OK);
	}	
	
	@ApiOperation(value = "Get users by userid", notes="This endpoint will give users by userid ")
	@GetMapping(path = "/getUser/{userid}")
	public ResponseEntity<List<ChatUser>> getUserById(@PathVariable("userid") String userId) {
		logger.info("inside Get user by id");
		List<ChatUser> getUserDetails = saveChatService.getUserdetails(userId);
		return new ResponseEntity<>(getUserDetails, HttpStatus.OK);
	}
	
	@ApiOperation(value = "Get all users ", notes="This endpoint will give all available users")
	@GetMapping(path = "/getUser")
	public ResponseEntity<List<ChatUser>> getAllUsers() {
		logger.info("inside Get all Users");
		List<ChatUser> getUserDetails = saveChatService.getAllUsers();
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
			logger.info("inside Get message by sender receiver");
			List<Messages> getMessageDetails = saveChatService.getMessagesBetweenTwo(sender, receiver, pageNumber, pageSize);
			return new ResponseEntity<>(saveChatService.convertToMessageDto(getMessageDetails), HttpStatus.OK);
		} catch (Exception e) {
			logger.info("Requester::error::sender ::" + sender);
			logger.info("Requester::error::receiver ::" + receiver);
			logger.error(e.getMessage(),e);
			List<MessagesDTO> messagesDTOS = saveChatService.getErrorMessage(e.getMessage());
			return new ResponseEntity<>(messagesDTOS, HttpStatus.INTERNAL_SERVER_ERROR);

		}
	}
	
	@ApiOperation(value = "Send notification to HSPA ", notes="this endpoint will send notification to HSPA based on given token ")
	@PostMapping("/notification/token")
    public ResponseEntity<PushNotificationResponse> sendTokenNotification(@RequestBody PushNotificationRequest request) {
			 try {
				pushNotificationService.sendPushNotificationToToken(request);
				logger.info("send notification");
			        return new ResponseEntity<>(new PushNotificationResponse(HttpStatus.OK.value(), "Notification has been sent."), HttpStatus.OK);
			} catch (InterruptedException | ExecutionException e) {
				logger.error("exception while sending notification"+e);
				Thread.currentThread().interrupt();
			        return new ResponseEntity<>(new PushNotificationResponse(HttpStatus.OK.value(), "some thing went wrong."), HttpStatus.BAD_REQUEST);
			}
		}
	@ApiOperation(value = "Save user token in database ", notes="app will hit this endpoint to save user token ")
	@PostMapping("/saveToken")
    public ResponseEntity<PushNotificationResponse> saveToken(@RequestBody RequestTokenDTO request) {
		UserToken saveUserToken = saveChatService.saveUserToken(request);
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
		logger.info("inside Get all Token Users");
	List<UserToken> allUserToken = saveChatService.getAllUserToken();
		return new ResponseEntity<>(allUserToken, HttpStatus.OK);
	}
	
	@PostMapping("/logout")
	public ResponseEntity<PushNotificationResponse> logout(@RequestBody RequestTokenDTO request) {
		PushNotificationResponse userToken = null;
	    try {	       
	        return saveChatService.deleteToken(request);
	    }
	    catch(RuntimeException re) {
	    	logger.error("Exception deleting token"+re);
	    	PushNotificationResponse errorMessage = getErrorMessage(re.getMessage()).get(0);
	        userToken = new PushNotificationResponse();
	        userToken.setError(errorMessage.getError());
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(userToken);
	    }
	}
	
	private List<? extends PushNotificationResponse> getErrorMessage(String message) {
		PushNotificationResponse messagesDTO = new PushNotificationResponse();
	    ErrorResponseDTO errorResponseDTO =  new ErrorResponseDTO();
	    errorResponseDTO.setErrorString(message);
	    errorResponseDTO.setCode("500");
	    errorResponseDTO.setPath("ChatController");
	    messagesDTO.setError(errorResponseDTO);

	    List<PushNotificationResponse> messagesDTOS = new ArrayList<>();
	    messagesDTOS.add(messagesDTO);
	    return messagesDTOS;
	}
	
	   
    @PostMapping("/saveKey")
    public ResponseEntity<SharedKey> savePublicKey(@RequestBody RequestSharedKeyDTO request) {
    	SharedKey saveSharedKey = saveChatService.saveSharedKey(request);
        if(null!= saveSharedKey)
        {
            return new ResponseEntity<>(saveSharedKey, HttpStatus.OK);
        }
        else
        {
            return new ResponseEntity<>(new SharedKey(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping(path = "/getKey/{userName}")
	public ResponseEntity<List<SharedKey>> getKeyByUsername(@PathVariable("userName") String userName){
    	logger.info("Get Key  by User Name");
		List<SharedKey> getKeyDetails = saveChatService.getKeyDetails(userName);		
		return new ResponseEntity<>(getKeyDetails,HttpStatus.OK);		
	}
    

	 @PostMapping("/uploadFile")
	    public UploadFileResponse uploadFile(@RequestParam("file") MultipartFile file) {
	        String fileName = fileStorageService.storeFile(file,uploadDir);

	        String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
	                .path("/downloadFile/")
	                .path(fileName)
	                .toUriString();

	        return new UploadFileResponse(fileName, fileDownloadUri,
	                file.getContentType(), file.getSize());
	    }

	    @PostMapping("/uploadMultipleFiles")
	    public List<UploadFileResponse> uploadMultipleFiles(@RequestParam("files") MultipartFile[] files) {
	        return Arrays.asList(files)
	                .stream()
	                .map(file -> uploadFile(file))
	                .collect(Collectors.toList());
	    }
	
	    @GetMapping("/downloadFile/{fileName}")
	    public ResponseEntity<Resource> downloadFile(@PathVariable String fileName, HttpServletRequest request) {
	        
	        Resource resource = fileStorageService.loadFileAsResource(fileName,uploadDir);	       
	        String contentType = null;
	        try {
	            contentType = request.getServletContext().getMimeType(resource.getFile().getAbsolutePath());
	        } catch (IOException ex) {
	        	logger.info("Could not determine file type."+ex);
	        }
	       
	        if(contentType == null) {
	            contentType = "application/octet-stream";
	        }

	        return ResponseEntity.ok()
	                .contentType(MediaType.parseMediaType(contentType))
	                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
	                .body(resource);
	    }

}
