package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.dto.CancelRequestDTO;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;
@Service
public class CancelService implements IService {
    private static final String API_RESOURCE_PATIENT = "patient";
    private static final String API_RESOURCE_APPOINTMENT = "appointmentscheduling/appointment";
    private static final String API_RESOURCE_APPOINTMENT_TIMESLOT = "appointmentscheduling/timeslot";
    private static final String API_RESOURCE_APPOINTMENT_TYPE = "appointmentscheduling/appointmenttype?v=custom:uuid,name&q=";
    private static final Logger LOGGER = LogManager.getLogger(CancelService.class);
    @Value("${spring.abdm_eua_url}")
    String EUA_URL;    
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    @Value("${spring.openmrs_api}")
    String OPENMRS_API;
    @Value("${spring.openmrs_username}")
    String OPENMRS_USERNAME;
    @Value("${spring.openmrs_password}")
    String OPENMRS_PASSWORD;
    @Value("${spring.gateway_uri}")
    String GATEWAY_URI;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.notificationService.baseUrl}")
	private String NOTIFICATION_SERVICE_BASE_URL;

    
    final
    WebClient webClient;
    final
    ObjectMapper mapper;

    final
    PaymentService paymentService;
    
    final
    CacheManager cacheManager;

    public CancelService(WebClient webClient, ObjectMapper mapper, PaymentService paymentService, CacheManager cacheManager) {
        this.webClient = webClient;
        this.mapper = mapper;
        this.paymentService = paymentService;
        this.cacheManager = cacheManager;
    }


    private static Response generateAck() {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("ACK");
        msz.setAck(ack);
        Error err = new Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    private static Response generateNack(Exception js) {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        Error err = new Error();
        err.setMessage(js.getMessage());
        err.setType("Search");
        res.setError(err);
        res.setMessage(msz);
        return res;
    }
    private static Mono<String> generateNackString() {
    	Mono<String> monores = null;
    	try {
    		MessageAck msz = new MessageAck();
    		Response res = new Response();
    		Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        Error err = new Error();
        err.setMessage("Order Not found in db");
        err.setType("Search");
        res.setError(err);
        res.setMessage(msz);
        ObjectMapper ob=new ObjectMapper();   
     
        monores= Mono.just(ob.writeValueAsString(res)) ;
		} catch (JsonProcessingException e) {
			LOGGER.error("PArsing error in nack");
			
		}
    	return monores;
        
    }

    @Override
    public Mono<Response> processor(String request) {
    	Request objRequest = new Request();
        Response ack = generateAck();

        LOGGER.info("Processing::Cancel::Request:: {}" , request);
        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            Request finalObjRequest = objRequest;
            logMessageId(objRequest);
            run(finalObjRequest, request);

        } catch (Exception ex) {
            LOGGER.error("Cancel Service process::error::onErrorResume:: {}", ex, ex);
            ack = generateNack(ex);

        }

        return Mono.just(ack);
    }

    @Override
    public Mono<String> run(Request request, String s) {

        Mono<String> response = Mono.empty();       
    	String orderId= request.getMessage().getOrder().getId();
    	 Map<String, String> fulfillmentTagsMap=request.getMessage().getOrder().getFulfillment().getTags();
         
         String key = fulfillmentTagsMap.get("@abdm/gov.in/cancelledby");
         String appointmentID="";
         List<OrdersModel> orders=null;
         if(key.equalsIgnoreCase(ConstantsUtils.PATIENT))
         {
        	orders= paymentService.getOrderDetailsByOrderId(orderId);
        	 if(!orders.isEmpty() ) {
        		 OrdersModel order=orders.get(0);
        		 appointmentID=order.getAppointmentId();  
        	 }
        	 else
        	 {
        		 LOGGER.info("Order Not found in db {}", request);
        		 return   generateNackString();
        	 }
        	 
         }
         else if(key.contains("doctor"))
         {
        	 appointmentID=orderId;
         }        
       
        
            final String finalappointmentId=appointmentID;
        	getAppointmentDetails(appointmentID)     	
                    .flatMap(result->cancelAppointment(result,finalappointmentId))
                    .flatMap(result->callOnCancel(result,request))
                    .flatMap(result->purgeAppointment(finalappointmentId,request))
                    .subscribe();
    
        return response;
    }
    


    private Mono<String> getAppointmentDetails(String  appointmentId) {
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT+"/"+appointmentId;
        String searchView = "?v=custom:status,timeSlot:(startDate,endDate)";

        return webClient.get()
                .uri(searchEndPoint + searchView)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }


    private Mono<String> cancelAppointment(String result,String appointmentId) {

        if(result.contains("SCHEDULED")) {       

            String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT+"/"+appointmentId;
     
            //TODO:get reason from eua cancel request 
            CancelRequestDTO cancel=new CancelRequestDTO();
            cancel.setStatus(ConstantsUtils.CANCELLED);
            cancel.setCancelReason("Canceled ");
            return webClient.post()
                    .uri(searchEndPoint)
                    .body(BodyInserters.fromValue(cancel))
                    .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
        }
        return Mono.just("Cancelationerror");
    }
    
    
    
    private Mono<String> callOnCancel(String result, Request request) {

    	if(result.contains("uuid"))
    	{
        request.getContext().setAction("on_cancel");         
            request.getMessage().getOrder().setState("CANCELLED");    
            
            
            String orderId= request.getMessage().getOrder().getId();
            Map<String, String> fulfillmentTagsMap=request.getMessage().getOrder().getFulfillment().getTags();               
            String key = fulfillmentTagsMap.get("@abdm/gov.in/cancelledby");
            List<OrdersModel> orders=null;
            if(key.equalsIgnoreCase(ConstantsUtils.PATIENT))
            {           
                 orders= paymentService.getOrderDetailsByOrderId(orderId);    
            }
            else if(key.contains("doctor"))
            {
            	orders= paymentService.getOrderDetailsByAppointmentId(orderId); 
            }
   		request.getContext().setProviderUri(PROVIDER_URI);
   		request.getContext().setConsumerUri(EUA_URL);
   			 if(!(orders != null && orders.isEmpty()))
                {
                	OrdersModel order= orders != null ? orders.get(0) : null;                                  
                     order.setIsServiceFulfilled("CANCELLED");
                     paymentService.saveOrderInDB(order);                   
                     request.getMessage().getOrder().setId(order.getOrderId());
                     if(key.equalsIgnoreCase(ConstantsUtils.PATIENT))
                     {   
                    	 WebClient on_webclient = WebClient.create();
                    	 on_webclient.post().uri(NOTIFICATION_SERVICE_BASE_URL+"/sendCancelNotification")
                    	 .body(BodyInserters.fromValue(order))
                    	 .retrieve()
                    	 .onStatus(HttpStatus::is4xxClientError,
      		            response -> response.bodyToMono(String.class).map(Exception::new))
                    	 .onStatus(HttpStatus::is5xxServerError,
      		            response -> response.bodyToMono(String.class).map(Exception::new))
                    	 .toEntity(String.class)
                    	 .doOnError(throwable -> {
                    		 LOGGER.error("Error sending notification--- {}" ,throwable.getMessage());
                    	 }).subscribe(res ->LOGGER.info("Sent notification--- {}" ,res.getBody()));
                     }
	
                }
   			 
                     

        WebClient on_webclient = WebClient.create();

        return on_webclient.post()
                .uri(EUA_URL + "/on_cancel")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Cancel Service call on cancel:: {}", error, error);
                    return Mono.empty(); //TODO:Add appropriate response
                });
    }
    else
    	{
    		 LOGGER.error("Error while cancelling appointment " );
    	}
    	
    	 return Mono.just("callOnCancel error");
    }

    private void logMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
    }
    
    private Mono<String> purgeAppointment(String appointmentId,Request request) {
    	try
    	{    		
            String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT+"/"+appointmentId;
        	String additionalParam="?!purge&reason=NA";
            return webClient.delete()
                    .uri(searchEndPoint+additionalParam)                    
                    .exchangeToMono(clientResponse ->  clientResponse.bodyToMono(String.class));
    		}

    	catch(Exception ex)
    		{

    			LOGGER.error("Error purging appointment {}. Requester message id is {}", ex.getMessage(), request.getContext().getMessageId());
    		}
      
        return Mono.just("error");
    }

    public Mono<String> logResponse(String result) {

        LOGGER.info("OnCancel::Log::Response:: {}", result);

        return Mono.just(result);
    }

}
