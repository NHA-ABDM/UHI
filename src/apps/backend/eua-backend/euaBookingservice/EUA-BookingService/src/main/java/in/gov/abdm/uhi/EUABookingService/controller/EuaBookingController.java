package in.gov.abdm.uhi.EUABookingService.controller;

import java.util.List;

import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;
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
	Logger LOGGER = LoggerFactory.getLogger(EuaBookingController.class);
	
	@Autowired
	SaveDataDbService savedatadb;

	@ApiOperation(value = "Save Initialized orders")
	@PostMapping(path = "/on_init")
	public ResponseEntity<Response> savedataForInit(@RequestBody @Valid Request request){
		LOGGER.info(request.getContext().getMessageId()+"Received request inside on_init "+request);	
		try
		{
		Orders saveDataInDb = savedatadb.saveDataInDb(request,ConstantsUtils.ON_INIT);
		return applyValidationForProviderUrlAndNullData(request, saveDataInDb);
		}
		catch(Exception e)
		{
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));		 
		}
		 
	}

	@ApiOperation(value = "Save Confirmed orders")
	@PostMapping(path = "/on_confirm")
	public ResponseEntity<Response> savedataForConfirm(@RequestBody @Valid Request request) {
		LOGGER.info(request.getContext().getMessageId()+"Received request inside on_confirm "+request);		
		Orders saveDataInDb;
		try {
			saveDataInDb = savedatadb.saveDataInDb(request,ConstantsUtils.ON_CONFIRM);
			return applyValidationForProviderUrlAndNullData(request, saveDataInDb);
		} 
		catch (UserException |JsonProcessingException e) {			
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO(e.getMessage()));
		} 
		catch (Exception e)
		{
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
		LOGGER.info("inside Get Orders");		
		List<Orders> getOrderDetails = savedatadb.getOrderDetails();		 
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get order by order id")
	@GetMapping(path = "/getOrdersByOrderid/{orderid}")
	public ResponseEntity<List<Orders>> getOrderByOrderid(@PathVariable("orderid") String orderid){	
		LOGGER.info("inside Get order by orderid");
		List<Orders> getOrderDetails = savedatadb.getOrderDetailsByOrderId(orderid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get order by abha id")
	@GetMapping(path = "/getOrdersByAbhaId/{abhaid}")
	public ResponseEntity<List<Orders>> getOrderByAbhaid(@PathVariable("abhaid") String abhaid){	
		LOGGER.info("inside Get order by abhaid");
		List<Orders> getOrderDetails = savedatadb.getOrderDetailsByAbhaId(abhaid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get Categories by category id")
	@GetMapping(path = "/getCategories/{categoryid}")
	public ResponseEntity<List<Categories>> getCategoriesByCategoryid(@PathVariable("categoryid") long categoryid){
		LOGGER.info("Get categories by categories id");
		List<Categories> getCategoriesDetails = savedatadb.getCategoriesDetails(categoryid);		
		return new ResponseEntity<>(getCategoriesDetails,HttpStatus.OK);		
	}
	
	@ApiOperation(value = "Get all categories")
	@GetMapping(path = "/getCategories")
	public ResponseEntity<List<Categories>> getCategories(){	
		LOGGER.info("inside Get Categories");
		List<Categories> getCategoriesDetails = savedatadb.getCategoriesDetails();		
		return new ResponseEntity<>(getCategoriesDetails,HttpStatus.OK);		
	}
	
	private ResponseEntity<Response> applyValidationForProviderUrlAndNullData(Request request,
			Orders saveDataInDb) {	

		if( request.getContext().getProviderUri().isBlank() )
		{		
				return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO("Provider url is blank"));
				
		}
		else if(saveDataInDb==null )
		{
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createNacknowledgementTO("error saving data"));
		}
		else
		{
			return ResponseEntity.status(HttpStatus.OK).body(createAcknowledgementTO());	
		}
		}

}
