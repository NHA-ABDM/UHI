package in.gov.abdm.uhi.EUABookingService.serviceImpl;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;
import in.gov.abdm.uhi.EUABookingService.entity.Categories;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.entity.Payments;
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
	Logger logger = LogManager.getLogger(SaveInDbServiceImpl.class);
	static final String INITSTATE = ConstantsUtils.INITIALIZED;

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
		logger.info(request.getContext().getMessageId() + " inside saveDataInDb");	
		saveCategoriesData(request);
			Orders saveOrderData = saveOrderData(request, action);
			validateOrderData(request, saveOrderData);
			if (action.equalsIgnoreCase(ConstantsUtils.ON_CONFIRM)) {
				Payments savePaymentsData = extractPaymentsData(request);
				if (savePaymentsData == null) {
					logger.error("Payment data not updated in db");	
					throw new UserException("Payment data not updated in db");
				}
				paymentRepo.save(savePaymentsData);
				saveOrderData.setPayment(savePaymentsData);
			}		
			return orderRepo.save(saveOrderData);			
	}

	public Categories saveCategoriesData(Request request) {	
		logger.info(request.getContext().getMessageId() + " inside saveCategoriesData");	
			Categories cat = new Categories();
			cat.setCategoryId(Long.parseLong(request.getMessage().getOrder().getItem().getId()));
			cat.setDescriptor(request.getMessage().getOrder().getItem().getDescriptor().getName());			
			return catRepo.save(cat);							
	}

	public Orders saveOrderData(Request request, String action) throws JsonProcessingException {	
		logger.info(request.getContext().getMessageId() + " inside saveOrderData");	
		return extractOrderDetails(request,action);
			
	}

	public Payments extractPaymentsData(Request request) {	
		logger.info(request.getContext().getMessageId() + " inside extractPaymentsData");	
			Payments p = extractPayments(request);			
			return checkForHealthIdIfNotThenTakeAbhaAddressForPayments(request, p);		
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
		return orderRepo.findByAbhaIdOrderByServiceFulfillmentStartTime(abhaid);
	}
	
	@Override
	public List<Orders> getOrderDetailsByAbhaIdDesc(String abhaid) {
		return orderRepo.findByAbhaIdOrderByServiceFulfillmentStartTimeDesc(abhaid);
	}

	@Override
	public List<Payments> getPaymentDetailsByTransactionId(String transactionid) {
		return paymentRepo.findByTransactionId(transactionid);
	}
	
	private Orders extractOrderDetails(Request request, String action) throws JsonProcessingException {
		logger.info(request.getContext().getMessageId() + " inside extractOrderDetails");	
		 String teleconUrl ="";
		Orders order = new Orders();
		order.setOrderId(request.getMessage().getOrder().getId());
		order.setCategoryId(request.getMessage().getOrder().getItem().getId());
		order.setHealthcareServiceName(request.getMessage().getOrder().getItem().getDescriptor().getName());
		order.setHealthcareServiceId(request.getMessage().getOrder().getItem().getId());
		
		if(request.getMessage().getOrder().getProvider().getDescriptor()!=null)
		{
			order.setHealthcareProfessionalName(request.getMessage().getOrder().getProvider().getDescriptor().getName());
			
		}
		if(null != request.getMessage().getOrder().getFulfillment().getTags()) {
			   Map<String, String> fulfillmentTagsMap = request.getMessage().getOrder().getFulfillment().getTags();
			   teleconUrl = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_TELECONSULTATION_URI);
			   order.setTeleconUrl(teleconUrl);
			}
		
		if(request.getMessage().getOrder().getFulfillment().getAgent()!=null)
		{
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
				Map<String, String> fulfillmentTagsMap = request.getMessage().getOrder().getFulfillment().getAgent().getTags();
					setGroupConsultationDetailsToOrderObject(order, fulfillmentTagsMap);
					
		}
			
			
			
		order.setServiceFulfillmentStartTime(
				request.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
		order.setServiceFulfillmentEndTime(
				request.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
		order.setServiceFulfillmentType(request.getMessage().getOrder().getFulfillment().getType());
		order.setHealthcareProviderUrl(request.getContext().getProviderUri());
		order.setPatientConsumerUrl(request.getContext().getConsumerUri());
		ObjectMapper objectMapper = new ObjectMapper();
		order.setMessage(objectMapper.writeValueAsString(request));
		order.setSlotId(request.getMessage().getOrder().getFulfillment().getId());
		order.setCategoryId(request.getMessage().getOrder().getItem().getId());
		order.setTransId(request.getContext().getTransactionId());
		order.setGroupConsultStatus(ConstantsUtils.False);
		


		String abha = request.getMessage().getOrder().getCustomer().getId();
		order= checkForHealthIdIfNotThenTakeAbhaAddress(request, order, abha);				
		return  changeStatusAsPerTransactionState(request, action, order);	
	}

	private void setGroupConsultationDetailsToOrderObject(Orders order, Map<String, String> fulfillmentTagsMap) {
		if (fulfillmentTagsMap != null) {
			String primaryDoctorHpr = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_PRIMARY_DOCTOR_HPR);
			String primaryDoctorName = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_PRIMARY_DOCTOR_NAME);
			String primaryDoctorGender = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_PRIMARY_DOCTOR_GENDER);
			String primaryDoctorUrl = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_PRIMARY_DOCTOR_PROVIDER_URL);

			String secondaryDoctorHpr = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_SECONDARY_DOCTOR_HPR);
			String secondaryDoctorName = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_SECONDARY_DOCTOR_NAME);
			String secondaryDoctorGender = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_SECONDARY_GENDER);
			String secondaryDoctorUrl = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_SECONDARY_DOCTOR_PROVIDER_URL);

			String patientGender = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_PATIENT_GENDER);

			String groupConsult = fulfillmentTagsMap.get(ConstantsUtils.ABDM_GOV_IN_GROUPCONSULT);

			boolean isprimaryDoctor = primaryDoctorHpr != null;
			boolean isprimaryDoctorName = primaryDoctorName != null;
			boolean isprimaryDoctorGender = primaryDoctorGender != null;
			boolean isprimaryDoctorUrl = primaryDoctorUrl != null;

			boolean issecondaryDoctorHpr = secondaryDoctorHpr != null;
			boolean issecondaryDoctorName = secondaryDoctorName != null;
			boolean issecondaryDoctorGender = secondaryDoctorGender != null;
			boolean issecondaryDoctorUrl = secondaryDoctorUrl != null;

			boolean isPatientgender = patientGender != null;

			boolean isgroupConsult = groupConsult != null;
			if (isgroupConsult && isprimaryDoctor && isprimaryDoctorName && isprimaryDoctorGender && isprimaryDoctorUrl) {
				order.setPrimaryDoctorHprAddress(primaryDoctorHpr);
				order.setPrimaryDoctorGender(primaryDoctorGender);
				order.setPrimaryDoctorName(primaryDoctorName);
				order.setPrimaryDoctorProviderURI(primaryDoctorUrl);
			}
			if (isgroupConsult && issecondaryDoctorName && issecondaryDoctorHpr && issecondaryDoctorGender && issecondaryDoctorUrl) {
				order.setSecondaryDoctorHprAddress(secondaryDoctorHpr);
				order.setSecondaryDoctorGender(secondaryDoctorGender);
				order.setSecondaryDoctorName(secondaryDoctorName);
				order.setSecondaryDoctorProviderURI(secondaryDoctorUrl);
			}
			if (isgroupConsult && isPatientgender ) {
				order.setGroupConsultStatus(groupConsult);
				order.setPatientGender(patientGender);
			}
		}
	}



	private Orders checkForHealthIdIfNotThenTakeAbhaAddress(Request request, Orders order, String abha) {
		logger.info(request.getContext().getMessageId() + " inside checkForHealthIdIfNotThenTakeAbhaAddress");	
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
			logger.error(request.getContext().getMessageId() + "  Order id is null or blank ");
			throw new UserException("Order id is null or blank");
		}		
	}
	
	private Orders changeStatusAsPerTransactionState(Request request, String action, Orders order) {
		if (action.equalsIgnoreCase(ConstantsUtils.ON_CONFIRM)) {
			order.setIsServiceFulfilled(request.getMessage().getOrder().getState());
		} else
		 order.setIsServiceFulfilled(INITSTATE);		
		return order;
	}
	
	private Payments extractPayments(Request request) {
		  Payments paymentModel = new Payments();
	        String paymentStatus=request.getMessage().getOrder().getPayment().getStatus();       
	        paymentModel.setTransactionId(request.getMessage().getOrder().getId());	        
	        paymentModel.setTransactionState(request.getMessage().getOrder().getPayment().getStatus());
	        if(paymentStatus.equalsIgnoreCase("PAID"))
	         {
	        	paymentModel.setTransactionId(request.getMessage().getOrder().getPayment().getParams().getTransaction_id());
	        	paymentModel.setMethod(request.getMessage().getOrder().getPayment().getUri());
		        paymentModel.setCurrency(request.getMessage().getOrder().getQuote().getPrice().getCurrency());
	        	paymentModel.setTransactionId(request.getMessage().getOrder().getPayment().getParams().getTransaction_id());
	        	paymentModel.setConsultationCharge(request.getMessage().getOrder().getQuote().getBreakup().get(0).getPrice().getValue());
	        	paymentModel.setPhrHandlingFees(request.getMessage().getOrder().getQuote().getBreakup().get(3).getPrice().getValue());
	        	paymentModel.setSgst(request.getMessage().getOrder().getQuote().getBreakup().get(2).getPrice().getValue());
	        	paymentModel.setCgst(request.getMessage().getOrder().getQuote().getBreakup().get(1).getPrice().getValue());
	         }
	        return paymentModel;
	}
	
	private Payments checkForHealthIdIfNotThenTakeAbhaAddressForPayments(Request request, Payments p) {
		String abha = request.getMessage().getOrder().getCustomer().getId();
		if (abha == null || abha.isBlank() || abha.isEmpty())
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getCred());
		else
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getId());
		return p;
	}

	@Override
	public Orders saveDataInDbCancel(Request request) {
		String orderid=request.getMessage().getOrder().getId();
		String state=request.getMessage().getOrder().getState();
		List<Orders> orders=getOrderDetailsByOrderId(orderid);
		if(!orders.isEmpty())
		{
			Orders order= orders.get(0);
			order.setIsServiceFulfilled(state);
			return orderRepo.save(order);
			
		}
		return null;
	}

	@Override
	public List<Orders> getOrderDetailsByFilterParams(String abhaid, String aType, Integer limit, String startDate, String endDate, String sort, String state) throws UserException {

		handleCustomErrorForMandatoryFields(aType, sort);

		List<Orders> ordersFilteredList = null;
		ordersFilteredList = handleSorting(abhaid, aType, sort, ordersFilteredList);
		ordersFilteredList = filterIfStartAndEndDateProvided(ordersFilteredList, startDate, endDate);
		ordersFilteredList = filterByState(state, ordersFilteredList);
		return handleLimitParameter(limit, ordersFilteredList);

	}


	public List<Orders> getOrderDetailsByAbhaIdAndType(String abhaid, String aType) {
		return orderRepo.findByAbhaIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(abhaid,aType);
	}



	private List<Orders> filterByState(String state, List<Orders> ordersFilteredList) {
		if(null != state) {
			ordersFilteredList = ordersFilteredList.stream().filter(res -> res.getIsServiceFulfilled().equalsIgnoreCase(state)).toList();

		}
		return ordersFilteredList;
	}

	private void handleCustomErrorForMandatoryFields(String aType, String sort) throws UserException {
		if(null == aType) {
			throw new UserException("Type cannot be null");
		}
		if(null == sort) {
			throw new UserException("sort cannot be null");
		}
	}

	private List<Orders> handleLimitParameter(Integer limit, List<Orders> ordersFilteredList) {
		if(limit != null && limit >= ordersFilteredList.size()) {
			return ordersFilteredList;
		}
		else if(limit != null)
			return ordersFilteredList.subList(0, limit);
		else
			return ordersFilteredList;
	}

	private List<Orders> handleSorting(String abhaid, String aType, String sort, List<Orders> ordersFilteredList) {
		if(sort.equalsIgnoreCase("ASC")) {
			ordersFilteredList =
					orderRepo.findByAbhaIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(abhaid, aType);
		}
		else if (sort.equalsIgnoreCase("DESC")) {
			ordersFilteredList =
					orderRepo.findByAbhaIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTimeDesc(abhaid, aType);
		}
		return ordersFilteredList;
	}

	private List<Orders> filterIfStartAndEndDateProvided(List<Orders> ordersFilteredList, String startDate, String endDate) {

		if(null != startDate && null!= endDate) {
			ordersFilteredList = ordersFilteredList.stream()
					.filter(res ->
					{
						String serviceFulfillmentStartTime = res.getServiceFulfillmentStartTime();
						String serviceFulFillmentEndTime = res.getServiceFulfillmentEndTime();
						if(serviceFulFillmentEndTime.length() >= 19 && serviceFulfillmentStartTime.length() >= 19 ) {
						return getLocalDateTimeFromString(serviceFulfillmentStartTime).isAfter(getLocalDateTimeFromString(startDate))
								&& getLocalDateTimeFromString(serviceFulFillmentEndTime).isBefore(getLocalDateTimeFromString(endDate));
						}
						return false;
					})
					.toList();

			return ordersFilteredList;
		}
		return ordersFilteredList;
	}


	private LocalDateTime getLocalDateTimeFromString(String request) {
		DateTimeFormatter ofPattern = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss", Locale.ENGLISH);
		return LocalDateTime.parse(request, ofPattern);

	}





}
