package in.gov.abdm.uhi.EUABookingService.service;

import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.EUABookingService.entity.Categories;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.entity.Payments;
import in.gov.abdm.uhi.EUABookingService.entity.User;
import in.gov.abdm.uhi.EUABookingService.exceptions.UserException;
import in.gov.abdm.uhi.common.dto.Request;

public interface SaveDataDbService {
	
Orders saveDataInDb(Request request ,String action ) throws UserException , JsonProcessingException;
	
	List<Orders> getOrderDetails();
	List<Categories> getCategoriesDetails();
	List<Categories> getCategoriesDetails(long s);
	List<Orders> getOrderDetailsByOrderId(String orderid);
	List<Orders> getOrderDetailsByAbhaId(String abhaid);
	List<Payments> getPaymentDetailsByTransactionId(String transactionid);
	

}
