package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.models.PaymentsModel;
import in.gov.abdm.uhi.hspa.repo.OrderRepository;
import in.gov.abdm.uhi.hspa.repo.PaymentsRepository;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@EnableAsync
public class PaymentService {

	Logger LOGGER = LoggerFactory.getLogger(PaymentService.class);
	final String INIT_STATE = ConstantsUtils.INITIALIZED;

	@Autowired
	OrderRepository orderRepo;

	@Autowired
	PaymentsRepository paymentRepo;

	public OrdersModel saveDataInDb(String uuid,Request request, String action) throws UserException, JsonProcessingException{		
		LOGGER.info(request.getContext().getMessageId() ,"{} inside saveDataInDb");
		OrdersModel saveOrderData = saveOrderData(request, action);	
		
			validateOrderData(request, saveOrderData);
			if (action.equalsIgnoreCase(ConstantsUtils.ON_CONFIRM)) {
				saveOrderData.setAppointmentId(uuid);
				PaymentsModel savePaymentsData = extractPaymentsData(request);
				if (savePaymentsData == null) {
					LOGGER.error("Payment data not updated in db");	
					throw new UserException("Payment data not updated in db");
				}
				paymentRepo.save(savePaymentsData);
				saveOrderData.setPayment(savePaymentsData);
			}
		return orderRepo.save(saveOrderData);
	}

	

	public OrdersModel saveOrderData(Request request, String action) throws JsonProcessingException {	
		LOGGER.info(request.getContext().getMessageId()  ,"{} inside saveOrderData");
		return extractOrderDetails(request,action);
	}

	public PaymentsModel extractPaymentsData(Request request) {	
		LOGGER.info(request.getContext().getMessageId() , "{} inside extractPaymentsData");
		PaymentsModel p = extractPayments(request);			
			return checkForHealthIdIfNotThenTakeAbhaAddress_ForPayments(request, p);		
	}

	public List<OrdersModel> getOrderDetails() {
		return orderRepo.findAll();
	}

	public List<OrdersModel> getOrderDetailsByOrderId(String orderid) {
		return orderRepo.findByOrderId(orderid);
	}
	
	public List<OrdersModel> getOrderDetailsByAppointmentId(String appointmentid) {
		return orderRepo.findByAppointmentId(appointmentid);
		
		
	}
	
	public List<OrdersModel> getOrderDetailsByAbhaId(String abhaid) {
		return orderRepo.findByAbhaIdOrderByServiceFulfillmentStartTime(abhaid);
	}
	public List<OrdersModel> getOrderDetailsByHprId(String hprid) {
		return orderRepo.findByHealthcareProfessionalIdOrderByServiceFulfillmentStartTime(hprid);
	}

	public List<PaymentsModel> getPaymentDetailsByTransactionId(String transactionid) {
		return paymentRepo.findByTransactionId(transactionid);
	}
	
	public OrdersModel saveOrderInDB(OrdersModel order)
	{
		return orderRepo.save(order);
	}
	public List<OrdersModel> getOrderDetailsByTransactionId(String transid) {
			return orderRepo.findByTransId(transid);
		}
	
	private OrdersModel extractOrderDetails(Request request, String action) throws JsonProcessingException {
		LOGGER.info(request.getContext().getMessageId() , " {} inside extractOrderDetails");
		OrdersModel order = new OrdersModel();
		order.setOrderId(request.getMessage().getOrder().getId());
		order.setCategoryId(request.getMessage().getOrder().getItem().getId());
		order.setHealthcareServiceName(request.getMessage().getOrder().getItem().getDescriptor().getName());
		order.setHealthcareServiceId(request.getMessage().getOrder().getItem().getId());
		order.setHealthcareProfessionalName(request.getMessage().getOrder().getFulfillment().getAgent().getName());
		order.setHealthcareProfessionalImage(
				request.getMessage().getOrder().getFulfillment().getAgent().getImage());
		order.setHealthcareProfessionalEmail(
				request.getMessage().getOrder().getFulfillment().getAgent().getEmail());
		order.setHealthcareProfessionalPhone(
				request.getMessage().getOrder().getFulfillment().getAgent().getPhone());
		order.setHealthcareProfessionalId(request.getMessage().getOrder().getFulfillment().getAgent().getId());
		order.setHealthcareProfessionalGender(
				request.getMessage().getOrder().getFulfillment().getAgent().getGender());
		order.setServiceFulfillmentStartTime(
				request.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
		order.setServiceFulfillmentEndTime(
				request.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
		order.setServiceFulfillmentType(request.getMessage().getOrder().getFulfillment().getType());
		order.setHealthcareProviderUrl(request.getContext().getProviderUri());
		ObjectMapper objectMapper = new ObjectMapper();
		order.setMessage(objectMapper.writeValueAsString(request));
		order.setSlotId(request.getMessage().getOrder().getFulfillment().getId());
		order.setCategoryId(request.getMessage().getOrder().getItem().getId());
		order.setPatientName(request.getMessage().getOrder().getBilling().getName());
		order.setTransId(request.getContext().getTransactionId());
		String abha = request.getMessage().getOrder().getCustomer().getId();
		checkForHealthIdIfNotThenTakeAbhaAddress(request, order, abha);
		return  changeStatusAsPerTransactionState(request, action, order);	
	}



	private OrdersModel checkForHealthIdIfNotThenTakeAbhaAddress(Request request, OrdersModel order, String abha) {
		LOGGER.info(request.getContext().getMessageId() , "{} inside checkForHealthIdIfNotThenTakeAbhaAddress");
		if (abha == null || abha.isBlank() || abha.isEmpty())
			order.setAbhaId(request.getMessage().getOrder().getCustomer().getCred());
		else
			order.setAbhaId(request.getMessage().getOrder().getCustomer().getId());		
		return order;
	}
	
	private void validateOrderData(Request request, OrdersModel saveOrderData) throws UserException {
		if (saveOrderData == null)
			throw new UserException("Error in request");		
		if (saveOrderData.getOrderId() == null || saveOrderData.getOrderId().isEmpty()) {
			LOGGER.error(request.getContext().getMessageId() ,"{}  Order id is null or blank ");
			throw new UserException("Order id is null or blank");
		}		
	}
	
	private OrdersModel changeStatusAsPerTransactionState(Request request, String action, OrdersModel order) {
		if (action.equalsIgnoreCase(ConstantsUtils.ON_CONFIRM)) {
			order.setIsServiceFulfilled(request.getMessage().getOrder().getState());
		} else
		 order.setIsServiceFulfilled(INIT_STATE);		
		return order;
	}
	
	private PaymentsModel extractPayments(Request request) {
		PaymentsModel p = new PaymentsModel();
		p.setTransactionId(request.getMessage().getOrder().getPayment().getParams().getTransaction_id());
		p.setMethod(request.getMessage().getOrder().getPayment().getUri());
		p.setCurrency(request.getMessage().getOrder().getQuote().getPrice().getCurrency());
		p.setConsultationCharge(
				request.getMessage().getOrder().getQuote().getBreakup().get(0).getPrice().getValue());
		p.setPhrHandlingFees(request.getMessage().getOrder().getQuote().getBreakup().get(3).getPrice().getValue());
		p.setSgst(request.getMessage().getOrder().getQuote().getBreakup().get(2).getPrice().getValue());
		p.setCgst(request.getMessage().getOrder().getQuote().getBreakup().get(1).getPrice().getValue());
		p.setTransactionState(request.getMessage().getOrder().getPayment().getStatus());
		return p;
	}
	
	private PaymentsModel checkForHealthIdIfNotThenTakeAbhaAddress_ForPayments(Request request, PaymentsModel p) {
		String abha = request.getMessage().getOrder().getCustomer().getId();
		if (abha == null || abha.isBlank() || abha.isEmpty())
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getCred());
		else
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getId());
		return p;
	}



	public List<OrdersModel> getOrderDetailsByHprIdAndType(String hprid, String aType) {
		return orderRepo.findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(hprid,aType);
	}




	
}