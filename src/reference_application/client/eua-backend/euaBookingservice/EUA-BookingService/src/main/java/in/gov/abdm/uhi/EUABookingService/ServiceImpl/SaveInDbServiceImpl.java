package in.gov.abdm.uhi.EUABookingService.serviceImpl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;
import in.gov.abdm.uhi.EUABookingService.entity.Categories;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.entity.Payments;
import in.gov.abdm.uhi.EUABookingService.entity.User;
import in.gov.abdm.uhi.EUABookingService.exceptions.UserException;
import in.gov.abdm.uhi.EUABookingService.repository.AddressRepository;
import in.gov.abdm.uhi.EUABookingService.repository.CategoriesRepository;
import in.gov.abdm.uhi.EUABookingService.repository.MessageRepository;
import in.gov.abdm.uhi.EUABookingService.repository.OrderRepository;
import in.gov.abdm.uhi.EUABookingService.repository.PaymentsRepository;
import in.gov.abdm.uhi.EUABookingService.repository.UserAbhaAddressRepository;
import in.gov.abdm.uhi.EUABookingService.repository.UserDeviceRepository;
import in.gov.abdm.uhi.EUABookingService.repository.UserRefreshTokenRepository;
import in.gov.abdm.uhi.EUABookingService.service.SaveDataDbService;
import in.gov.abdm.uhi.common.dto.Request;

@Repository
public class SaveInDbServiceImpl implements SaveDataDbService {
	Logger LOGGER = LoggerFactory.getLogger(SaveInDbServiceImpl.class);
	final String INIT_STATE = ConstantsUtils.INITIALIZED;

	@Autowired
	AddressRepository addressRepo;

	@Autowired
	CategoriesRepository catRepo;

	@Autowired
	MessageRepository msgRepo;

	@Autowired
	OrderRepository orderRepo;

	@Autowired
	PaymentsRepository paymentRepo;

	@Autowired
	UserAbhaAddressRepository userabhaaddress;

	@Autowired
	UserDeviceRepository userDeviceRepo;

	@Autowired
	UserRefreshTokenRepository userRefTokenRepo;



	@Override
	public Orders saveDataInDb(Request request, String action) throws UserException, JsonProcessingException{		
		LOGGER.info(request.getContext().getMessageId() + " inside saveDataInDb");	
		saveCategoriesData(request);
			Orders saveOrderData = saveOrderData(request, action);
			validateOrderData(request, saveOrderData);
			if (action.equalsIgnoreCase(ConstantsUtils.ON_CONFIRM)) {
				Payments savePaymentsData = extractPaymentsData(request);
				if (savePaymentsData == null) {
					LOGGER.error("Payment data not updated in db");	
					throw new UserException("Payment data not updated in db");
				}
				paymentRepo.save(savePaymentsData);
				saveOrderData.setPayment(savePaymentsData);
			}		
			Orders save = orderRepo.save(saveOrderData);
			return save;
	}

	public Categories saveCategoriesData(Request request) {	
		LOGGER.info(request.getContext().getMessageId() + " inside saveCategoriesData");	
			Categories cat = new Categories();
			cat.setCategoryId(Long.parseLong(request.getMessage().getOrder().getItem().getId()));
			cat.setDescriptor(request.getMessage().getOrder().getItem().getDescriptor().getName());			
			return catRepo.save(cat);							
	}

	public Orders saveOrderData(Request request, String action) throws JsonProcessingException {	
		LOGGER.info(request.getContext().getMessageId() + " inside saveOrderData");	
			Orders order = extractOrderDetails(request,action);
			return order;
	}

	public Payments extractPaymentsData(Request request) {	
		LOGGER.info(request.getContext().getMessageId() + " inside extractPaymentsData");	
			Payments p = extractPayments(request);			
			return checkForHealthIdIfNotThenTakeAbhaAddress_ForPayments(request, p);		
	}


	@Override
	public List<Orders> getOrderDetails() {
		return orderRepo.findAll();
	}

	@Override
	public List<Orders> getOrderDetailsByOrderId(String orderid) {
		return orderRepo.findByOrderId(orderid);
	}

	@Override
	public List<Categories> getCategoriesDetails(long categoryid) {
		return catRepo.findByCategoryId(categoryid);
	}

	@Override
	public List<Categories> getCategoriesDetails() {
		return catRepo.findAll();
	}

	@Override
	public List<Orders> getOrderDetailsByAbhaId(String abhaid) {
		return orderRepo.findByAbhaId(abhaid);
	}

	@Override
	public List<Payments> getPaymentDetailsByTransactionId(String transactionid) {
		return paymentRepo.findByTransactionId(transactionid);
	}
	
	private Orders extractOrderDetails(Request request, String action) throws JsonProcessingException {
		LOGGER.info(request.getContext().getMessageId() + " inside extractOrderDetails");	
		Orders order = new Orders();
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
		String abha = request.getMessage().getOrder().getCustomer().getId();
		order= checkForHealthIdIfNotThenTakeAbhaAddress(request, order, abha);				
		return  changeStatusAsPerTransactionState(request, action, order);	
	}



	private Orders checkForHealthIdIfNotThenTakeAbhaAddress(Request request, Orders order, String abha) {
		LOGGER.info(request.getContext().getMessageId() + " inside checkForHealthIdIfNotThenTakeAbhaAddress");	
		if (abha == null || abha.isBlank() || abha.isEmpty())
			order.setAbhaId(request.getMessage().getOrder().getCustomer().getCred());
		else
			order.setAbhaId(request.getMessage().getOrder().getCustomer().getId());		
		return order;
	}
	
	private void validateOrderData(Request request, Orders saveOrderData) throws UserException {
		if (saveOrderData == null)
			throw new UserException("Error in request");		
		if (saveOrderData.getOrderId() == null || saveOrderData.getOrderId().isEmpty()) {
			LOGGER.error(request.getContext().getMessageId() + "  Order id is null or blank ");
			throw new UserException("Order id is null or blank");
		}		
	}
	
	private Orders changeStatusAsPerTransactionState(Request request, String action, Orders order) {
		if (action.equalsIgnoreCase(ConstantsUtils.ON_CONFIRM)) {
			order.setIsServiceFulfilled(request.getMessage().getOrder().getState());
		} else
		 order.setIsServiceFulfilled(INIT_STATE);		
		return order;
	}
	
	private Payments extractPayments(Request request) {
		Payments p = new Payments();
		p.setTransactionId(request.getMessage().getOrder().getPayment().getParams().getTransaction_id());
		p.setMethod(request.getMessage().getOrder().getPayment().getUri());
		p.setCurrency(request.getMessage().getOrder().getQuote().getPrice().getCurrency());
		// p.setTransactionTimestamp(null);
		p.setConsultationCharge(
				request.getMessage().getOrder().getQuote().getBreakup().get(0).getPrice().getValue());
		p.setPhrHandlingFees(request.getMessage().getOrder().getQuote().getBreakup().get(3).getPrice().getValue());
		p.setSgst(request.getMessage().getOrder().getQuote().getBreakup().get(2).getPrice().getValue());
		p.setCgst(request.getMessage().getOrder().getQuote().getBreakup().get(1).getPrice().getValue());
		p.setTransactionState(request.getMessage().getOrder().getPayment().getStatus());
		return p;
	}
	
	private Payments checkForHealthIdIfNotThenTakeAbhaAddress_ForPayments(Request request, Payments p) {
		String abha = request.getMessage().getOrder().getCustomer().getId();
		if (abha == null || abha.isBlank() || abha.isEmpty())
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getCred());
		else
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getId());
		return p;
	}



}
