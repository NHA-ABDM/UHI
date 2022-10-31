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
import org.springframework.transaction.annotation.Transactional;
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

        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            LOGGER.info("Processing::Cancel::Request:: {}, Message Id is {}" , request, getMessageId(objRequest));

            Request finalObjRequest = objRequest;
            run(finalObjRequest, request);

        } catch (Exception ex) {
            LOGGER.error("Cancel Service process::error::onErrorResume:: {}, Message Id is {}", ex, getMessageId(objRequest));
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
        		 LOGGER.info("Order Not found in db {}, .. Message Id is {}", request, getMessageId(request));
        		 return generateNackString();
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
                    .flatMap(result->cancelSecondOrder(request, result))
                    .flatMap(reulut->purgeAppointment(finalappointmentId,request))
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
    
    
    
    private Mono<OrdersModel> callOnCancel(String result, Request request)  {
    	Mono<String> oncancel=null;
    	OrdersModel order=null;
    	if(result.contains("uuid"))
    	{
        request.getContext().setAction("on_cancel");         
            request.getMessage().getOrder().setState("CANCELLED");    
            
            
            String orderId= request.getMessage().getOrder().getId();
            Map<String, String> fulfillmentTagsMap=request.getMessage().getOrder().getFulfillment().getTags();               
            String key = fulfillmentTagsMap.get("@abdm/gov.in/cancelledby");
            List<OrdersModel> orders=null;
            orders = getOrdersBasedOnPersonCancelling(orderId, key, orders);
   		request.getContext().setProviderUri(PROVIDER_URI);
   			 order = callNotificatonService(request, order, key, orders);
        oncancel = callOnCancelWebClient(request);       
        return Mono.just(order);       
        
    }
    else
    	{
    		 LOGGER.error("Error while cancelling appointment \n Message Id is {}", getMessageId(request) );
    		 return Mono.just(null);
    	}   	
    }


	private Mono<String> cancelSecondOrder(Request request, OrdersModel order) {
		  Map<String, String> fulfillmentTagsMap=request.getMessage().getOrder().getFulfillment().getTags();     
		 String key = fulfillmentTagsMap.get("@abdm/gov.in/cancelledby");
		 boolean isDoctor = key.contains("doctor");
		if(isDoctor)
        {
        
        List<OrdersModel> od=paymentService.getOrderDetailsByTransactionId(order.getTransId());
  	   String ordId=order.getOrderId();
			List<OrdersModel> otherDrOrder = od
					  .stream()
					  .filter(c -> !(c.getOrderId().equalsIgnoreCase(ordId)) && c.getIsServiceFulfilled().equalsIgnoreCase(ConstantsUtils.CONFIRMED))
					  .toList();
			if(!otherDrOrder.isEmpty())
			{
				
				OrdersModel grporder1=otherDrOrder.get(0);	
				
				request.getMessage().getOrder().setId(grporder1.getOrderId());
				request.getMessage().getOrder().setState(ConstantsUtils.CANCELLED);
				request.getMessage().getOrder().getFulfillment().getTags().put("@abdm/gov.in/cancelledby",ConstantsUtils.PATIENT);
				request.getContext().setAction(ConstantsUtils.CANCEL);
				ObjectMapper objectMapper = new ObjectMapper();					
				try {
					processor(objectMapper.writeValueAsString(request));
				} catch (JsonProcessingException e) {
				
					 LOGGER.error(e.getMessage());
				}
					
			
			}
        }
		return Mono.empty();
	}


	private Mono<String> callOnCancelWebClient(Request request) {
		Mono<String> oncancel;
		
       
        oncancel= webClient.post()
                .uri(request.getContext().getConsumerUri() + "/on_cancel")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(String.class)   
				.retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Cancel Service call on cancel:: {} \n Message Id is {}", error, getMessageId(request));
                    return Mono.empty(); //TODO:Add appropriate response
                })				
                ;
        oncancel.subscribe(e-> LOGGER.info("%%%%%%%%%%%%%%%"+e));
        
		return oncancel;
	}


	private OrdersModel callNotificatonService(Request request, OrdersModel order, String key,
			List<OrdersModel> orders) {
		if(!(orders.isEmpty()))
		    {
		    	 order= orders != null ? orders.get(0) : null;
		        if (order != null) {
		            order.setIsServiceFulfilled("CANCELLED");

		            paymentService.saveOrderInDB(order);
		            request.getMessage().getOrder().setId(order.getOrderId());
		            if (key.equalsIgnoreCase(ConstantsUtils.PATIENT)) {
		                WebClient on_webclient = WebClient.create();
		                on_webclient.post().uri(NOTIFICATION_SERVICE_BASE_URL + "/sendCancelNotification")
		                        .body(BodyInserters.fromValue(order))
		                        .retrieve()
		                        .onStatus(HttpStatus::is4xxClientError,
		                                response -> response.bodyToMono(String.class).map(Exception::new))
		                        .onStatus(HttpStatus::is5xxServerError,
		                                response -> response.bodyToMono(String.class).map(Exception::new))
		                        .toEntity(String.class)
		                        .doOnError(throwable -> LOGGER.error("Error sending notification--- {} .. Message Id is {}", throwable.getMessage(), getMessageId(request))).subscribe(res -> LOGGER.info("Sent notification--- {} .. Message Id is {}", getMessageId(request), res.getBody()));
		            }
		        }
		        else {
		            LOGGER.error("CancelService :: callOnCancel :: error .. Orders are null.. Message Id is {}", getMessageId(request));
		        }
		    }
		return order;
	}


	private List<OrdersModel> getOrdersBasedOnPersonCancelling(String orderId, String key, List<OrdersModel> orders) {
		if(key.equalsIgnoreCase(ConstantsUtils.PATIENT))
		{           
		     orders= paymentService.getOrderDetailsByOrderId(orderId);    
		}
		else if(key.contains("doctor"))
		{
			orders= paymentService.getOrderDetailsByAppointmentId(orderId); 
		}
		return orders;
	}

    private String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
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


    public Mono<String> logResponse(String result, Request request) {
        LOGGER.info("OnCancel::Log::Response:: {}, \n Message Id is ", result, getMessageId(request));
        return Mono.just(result);
    }

}
