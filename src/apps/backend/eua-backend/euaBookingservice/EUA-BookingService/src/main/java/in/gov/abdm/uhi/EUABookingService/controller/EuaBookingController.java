package in.gov.abdm.uhi.EUABookingService.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;
import javax.validation.Valid;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.core.JsonProcessingException;

import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;
import in.gov.abdm.uhi.EUABookingService.dto.ErrorResponseDTO;
import in.gov.abdm.uhi.EUABookingService.dto.ServiceResponseDTO;
import in.gov.abdm.uhi.EUABookingService.entity.Categories;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.exceptions.UserException;
import in.gov.abdm.uhi.EUABookingService.service.SaveDataDbService;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
@RestController
@RequestMapping(value = "/api/v1/bookingService")
@Api(tags = "Booking Service", value = "Bookingservice")
public class EuaBookingController {
	Logger logger = LogManager.getLogger(EuaBookingController.class);
	
	@Autowired
	SaveDataDbService savedatadb;
	
	@Autowired
	private SimpMessagingTemplate messagingTemplate;
	
	@Autowired
	WebClient webclient;
	
	@Value("${spring.notificationService.baseUrl}")
	private String notificationServiceBaseUrl;
 
	
	@ApiOperation(value = "Save Initialized orders")
	@PostMapping(path = "/on_init")
	public ResponseEntity<Response> savedataForInit(@RequestBody @Valid Request request){
		ObjectMapper objectMapper = new ObjectMapper();
		
		try
		{
			logger.info(request.getContext().getMessageId()+"Received request inside on_init "+objectMapper.writeValueAsString(request));	
		Orders saveDataInDb = savedatadb.saveDataInDb(request,ConstantsUtils.ON_INIT);
		return applyValidationForProviderUrlAndNullData(request, saveDataInDb);
		}
		catch(Exception e)
		{
			logger.error("Exception in on_init"+e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));		 
		}
		 
	}

	@ApiOperation(value = "Save Confirmed orders")
	@PostMapping(path = "/on_confirm")
	public ResponseEntity<Response> savedataForConfirm(@RequestBody @Valid Request request) {
		ObjectMapper objectMapper = new ObjectMapper();
		
		Orders saveDataInDb;
		try {
			logger.info(request.getContext().getMessageId()+"Received request inside on_confirm "+objectMapper.writeValueAsString(request));		
			saveDataInDb = savedatadb.saveDataInDb(request,ConstantsUtils.ON_CONFIRM);		
			return applyValidationForProviderUrlAndNullData(request, saveDataInDb);
		} 
		catch (UserException |JsonProcessingException e) {		
			logger.error("Exception in on_confirm"+e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));
		} 
		catch (Exception e)
		{
			logger.error("Exception in on_confirm"+e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));
		}
		
		 
	}

	@PostMapping(path = "/on_status")
	public ResponseEntity<Response> savedataForOnStatus(@RequestBody @Valid Request request) {
		ObjectMapper objectMapper = new ObjectMapper();

		Orders saveDataInDb;
		try {
			logger.info(request.getContext().getMessageId()+"Received request inside on_status "+objectMapper.writeValueAsString(request));
			saveDataInDb = savedatadb.saveDataInDb(request,ConstantsUtils.ON_CONFIRM);
			return applyValidationForProviderUrlAndNullData(request, saveDataInDb);
		}
		catch (UserException |JsonProcessingException e) {
			logger.error("Exception in on_status"+e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));
		}
		catch (Exception e)
		{
			logger.error("Exception in on_confirm"+e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));
		}


	}
	
	@PostMapping(path = "/on_cancel")
	public ResponseEntity<Response> savedataForCancel(@RequestBody @Valid Request request) {
		ObjectMapper objectMapper = new ObjectMapper();
		
		Orders saveDataInDb;
		try {
			logger.info(request.getContext().getMessageId()+"Received request inside on_cancel "+objectMapper.writeValueAsString(request));	

			saveDataInDb = savedatadb.saveDataInDbCancel(request);		
			Map<String, String> fulfillmentTagsMap=request.getMessage().getOrder().getFulfillment().getTags();               
            String key = fulfillmentTagsMap.get("@abdm/gov.in/cancelledby");	
            messagingTemplate.convertAndSendToUser(request.getContext().getMessageId(), "/queue/specific-user", request);
			 if(key.equalsIgnoreCase("doctor"))
             {   
            	 WebClient onwebClient = WebClient.create();
            	 onwebClient.post().uri(notificationServiceBaseUrl+"/sendCancelNotification")
            	 .body(BodyInserters.fromValue(saveDataInDb))
            	 .retrieve()
            	 .onStatus(HttpStatus::is4xxClientError,
		            response -> response.bodyToMono(String.class).map(Exception::new))
            	 .onStatus(HttpStatus::is5xxServerError,
		            response -> response.bodyToMono(String.class).map(Exception::new))
            	 .toEntity(String.class)
            	 .doOnError(throwable -> {
            		 logger.error("Error sending notification---"+throwable.getMessage());
            	 }).subscribe(res ->logger.info("Sent notification---"+res.getBody()));
             }
			return applyValidationForProviderUrlAndNullData(request, saveDataInDb);
		} 
	
		catch (Exception e)
		{
			logger.error("Exception in on_cancel"+e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));
		}
		
		 
	}
	
	private Response createAcknowledgementTO() {
		Ack ack = new Ack("ACK");
		MessageAck ackMessage = new MessageAck(ack);
		return new Response(ackMessage, null);
		}
	
	private Response createNacknowledgementTO(String error) {
		Error err= new Error();
		err.setMessage(error);		
		Ack ack = new Ack("NACK");
		MessageAck ackMessage = new MessageAck(ack);
		return new Response(ackMessage, err);
		}
	
	
	@ApiOperation(value = "Get all Orders")
	@GetMapping(path = "/getOrders")
	public ResponseEntity<List<Orders>> getOrders(){		
		logger.info("inside Get Orders");		
		List<Orders> getOrderDetails = savedatadb.getOrderDetails();		 
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get order by order id")
	@GetMapping(path = "/getOrdersByOrderid/{orderid}")
	public ResponseEntity<List<Orders>> getOrderByOrderid(@PathVariable("orderid") String orderid){	
		logger.info("inside Get order by orderid");
		List<Orders> getOrderDetails = savedatadb.getOrderDetailsByOrderId(orderid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get order by abha id")
	@GetMapping(path = "/getOrdersByAbhaId/{abhaid}")
	public ResponseEntity<List<Orders>> getOrderByAbhaid(@PathVariable("abhaid") String abhaid){	
		logger.info("inside Get order by abhaid");
		List<Orders> getOrderDetails = savedatadb.getOrderDetailsByAbhaId(abhaid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@GetMapping(path = "/getOrdersByAbhaIdDesc/{abhaid}")
	public ResponseEntity<List<Orders>> getOrderByAbhaidDesc(@PathVariable("abhaid") String abhaid){	
		logger.info("inside Get order by abhaid");
		List<Orders> getOrderDetails = savedatadb.getOrderDetailsByAbhaIdDesc(abhaid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get Categories by category id")
	@GetMapping(path = "/getCategories/{categoryid}")
	public ResponseEntity<List<Categories>> getCategoriesByCategoryid(@PathVariable("categoryid") long categoryid){
		logger.info("Get categories by categories id");
		List<Categories> getCategoriesDetails = savedatadb.getCategoriesDetails(categoryid);		
		return new ResponseEntity<>(getCategoriesDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get all categories")
	@GetMapping(path = "/getCategories")
	public ResponseEntity<List<Categories>> getCategories(){	
		logger.info("inside Get Categories");
		List<Categories> getCategoriesDetails = savedatadb.getCategoriesDetails();		
		return new ResponseEntity<>(getCategoriesDetails,HttpStatus.OK);		
	}
	
	
	
	@GetMapping(path = "/getOrdersByAbhaIdAndType/{abhaid}")
	public ResponseEntity<List<Orders>> getOrderByAbhaidAndType(@PathVariable("abhaid") String abhaid,
                                                                    @RequestParam(value ="limit",defaultValue="100",required=false)Integer limit,
                                                                    @RequestParam(value ="aType", required = false)String aType,
                                                                    @RequestParam(value ="startDate", required = false) String startDate,
                                                                    @RequestParam(value ="endDate", required = false) String endDate,
                                                                    @RequestParam(value ="sort", required = false) String sort,
                                                                    @RequestParam(value ="state", required = false) String state) {
		logger.info("inside Get order by abhaid and type");

        List<Orders> getOrderDetails = null;
        try {
            getOrderDetails = savedatadb.getOrderDetailsByFilterParams(abhaid, aType, limit, startDate, endDate, sort, state);
        } catch (Exception e) {
        	logger.error("EUAController :: /getOrdersByAbhaIdAndType/{abhaid}:: error {}", e.getMessage());
        	Orders error = new Orders();
            ServiceResponseDTO messagesDTO = new ServiceResponseDTO();
            ErrorResponseDTO errorResponseDTO =  new ErrorResponseDTO();
            errorResponseDTO.setErrorString(e.getMessage());
            errorResponseDTO.setCode("500");
            errorResponseDTO.setPath("EUAController");
            messagesDTO.setError(errorResponseDTO);
            error.setError(errorResponseDTO);
            List<Orders> errorDto = new ArrayList<>();
            errorDto.add(error);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorDto);
        }
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }
	
	
	
	
	private ResponseEntity<Response> applyValidationForProviderUrlAndNullData(Request request,
			Orders saveDataInDb) {	

		if( request.getContext().getProviderUri().isBlank() )
		{		
				return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO("Provider url is blank"));
				
		}
		else if(saveDataInDb==null )
		{
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO("error saving data order id not present"));
		}
		else
		{
			return ResponseEntity.status(HttpStatus.OK).body(createAcknowledgementTO());	
		}
		}

}
