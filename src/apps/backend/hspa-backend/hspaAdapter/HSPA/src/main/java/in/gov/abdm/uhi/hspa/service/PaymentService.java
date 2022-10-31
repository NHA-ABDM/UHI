package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.models.PaymentsModel;
import in.gov.abdm.uhi.hspa.repo.OrderRepository;
import in.gov.abdm.uhi.hspa.repo.PaymentsRepository;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static in.gov.abdm.uhi.hspa.utils.ConstantsUtils.*;

@Repository
@EnableAsync
public class PaymentService {

	Logger LOGGER = LoggerFactory.getLogger(PaymentService.class);
	static final String INIT_STATE = INITIALIZED;

	final OrderRepository orderRepo;

	final PaymentsRepository paymentRepo;

	final ModelMapper modelMapper;

	public PaymentService(OrderRepository orderRepo, PaymentsRepository paymentRepo, ModelMapper modelMapper) {
		this.orderRepo = orderRepo;
		this.paymentRepo = paymentRepo;
		this.modelMapper = modelMapper;
	}

	public OrdersModel saveDataInDb(String uuid, Request request, String action)
			throws UserException, JsonProcessingException {
		LOGGER.info(request.getContext().getMessageId(), "{} inside saveDataInDb");
		OrdersModel saveOrderData = saveOrderData(request, action);

		validateOrderData(request, saveOrderData);
		if (action.equalsIgnoreCase(ON_CONFIRM)) {
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
		LOGGER.info(request.getContext().getMessageId(), "{} inside saveOrderData");
		return extractOrderDetails(request, action);
	}

	public PaymentsModel extractPaymentsData(Request request) {
		LOGGER.info(request.getContext().getMessageId(), "{} inside extractPaymentsData");
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

	public OrdersModel saveOrderInDB(OrdersModel order) {
		return orderRepo.save(order);
	}

	public List<OrdersModel> getOrderDetailsByTransactionId(String transid) {
		return orderRepo.findByTransId(transid);
	}

	private OrdersModel extractOrderDetails(Request request, String action) throws JsonProcessingException {
		LOGGER.info(request.getContext().getMessageId(), " {} inside extractOrderDetails");
		OrdersModel order = new OrdersModel();
		order.setOrderId(request.getMessage().getOrder().getId());
		order.setCategoryId(request.getMessage().getOrder().getItem().getId());
		order.setHealthcareServiceName(request.getMessage().getOrder().getItem().getDescriptor().getName());
		order.setHealthcareServiceId(request.getMessage().getOrder().getItem().getId());
//        order.setPatientConsumerUrl(request.getContext().getConsumerUri());
		order.setHealthcareProfessionalName(request.getMessage().getOrder().getFulfillment().getAgent().getName());
		order.setHealthcareProfessionalImage(request.getMessage().getOrder().getFulfillment().getAgent().getImage());
		order.setHealthcareProfessionalEmail(request.getMessage().getOrder().getFulfillment().getAgent().getEmail());
		order.setHealthcareProfessionalPhone(request.getMessage().getOrder().getFulfillment().getAgent().getPhone());
		order.setHealthcareProfessionalId(request.getMessage().getOrder().getFulfillment().getAgent().getId());
		order.setHealthcareProfessionalGender(request.getMessage().getOrder().getFulfillment().getAgent().getGender());
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
		order.setGroupConsultStatus(False);
		Map<String, String> fulfillmentTagsMap = request.getMessage().getOrder().getFulfillment().getAgent().getTags();
		setGroupConsultationDetailsToOrderObject(order, fulfillmentTagsMap);

		String abha = request.getMessage().getOrder().getCustomer().getId();
		checkForHealthIdIfNotThenTakeAbhaAddress(request, order, abha);
		return changeStatusAsPerTransactionState(request, action, order);
	}

	private void setGroupConsultationDetailsToOrderObject(OrdersModel order, Map<String, String> fulfillmentTagsMap) {
		if (fulfillmentTagsMap != null) {
			String primaryDoctorHpr = fulfillmentTagsMap.get(ABDM_GOV_IN_PRIMARY_DOCTOR_HPR);
			String primaryDoctorName = fulfillmentTagsMap.get(ABDM_GOV_IN_PRIMARY_DOCTOR_NAME);
			String primaryDoctorGender = fulfillmentTagsMap.get(ABDM_GOV_IN_PRIMARY_DOCTOR_GENDER);
			String primaryDoctorUrl = fulfillmentTagsMap.get(ABDM_GOV_IN_PRIMARY_DOCTOR_PROVIDER_URL);

			String secondaryDoctorHpr = fulfillmentTagsMap.get(ABDM_GOV_IN_SECONDARY_DOCTOR_HPR);
			String secondaryDoctorName = fulfillmentTagsMap.get(ABDM_GOV_IN_SECONDARY_DOCTOR_NAME);
			String secondaryDoctorGender = fulfillmentTagsMap.get(ABDM_GOV_IN_SECONDARY_GENDER);
			String secondaryDoctorUrl = fulfillmentTagsMap.get(ABDM_GOV_IN_SECONDARY_DOCTOR_PROVIDER_URL);

			String patientGender = fulfillmentTagsMap.get(ABDM_GOV_IN_PATIENT_GENDER);
			String consumerUrl = fulfillmentTagsMap.get(ABDM_GOV_IN_CONSUMER_URL);

			String groupConsult = fulfillmentTagsMap.get(ABDM_GOV_IN_GROUPCONSULT);

			boolean isprimaryDoctor = primaryDoctorHpr != null;
			boolean isprimaryDoctorName = primaryDoctorName != null;
			boolean isprimaryDoctorGender = primaryDoctorGender != null;
			boolean isprimaryDoctorUrl = primaryDoctorUrl != null;

			boolean issecondaryDoctorHpr = secondaryDoctorHpr != null;
			boolean issecondaryDoctorName = secondaryDoctorName != null;
			boolean issecondaryDoctorGender = secondaryDoctorGender != null;
			boolean issecondaryDoctorUrl = secondaryDoctorUrl != null;

			boolean isPatientgender = patientGender != null;
			boolean isConsumerUrl = consumerUrl != null;

			boolean isgroupConsult = groupConsult != null;
			if (!isgroupConsult) {
				groupConsult = "false";
			}
			if (isgroupConsult && isprimaryDoctor && isprimaryDoctorName && isprimaryDoctorGender
					&& isprimaryDoctorUrl) {
				order.setPrimaryDoctorHprAddress(primaryDoctorHpr);
				order.setPrimaryDoctorGender(primaryDoctorGender);
				order.setPrimaryDoctorName(primaryDoctorName);
				order.setPrimaryDoctorProviderURI(primaryDoctorUrl);
			}
			if (isgroupConsult && issecondaryDoctorName && issecondaryDoctorHpr && issecondaryDoctorGender
					&& issecondaryDoctorUrl) {
				order.setSecondaryDoctorHprAddress(secondaryDoctorHpr);
				order.setSecondaryDoctorGender(secondaryDoctorGender);
				order.setSecondaryDoctorName(secondaryDoctorName);
				order.setSecondaryDoctorProviderURI(secondaryDoctorUrl);
			}
			if (isgroupConsult && isPatientgender && isConsumerUrl) {
				order.setGroupConsultStatus(groupConsult);
				order.setPatientConsumerUrl(consumerUrl);
				order.setPatientGender(patientGender);
			}
		}
	}

	private OrdersModel checkForHealthIdIfNotThenTakeAbhaAddress(Request request, OrdersModel order, String abha) {
		LOGGER.info(request.getContext().getMessageId(), "{} inside checkForHealthIdIfNotThenTakeAbhaAddress");
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
			LOGGER.error(request.getContext().getMessageId(), "{}  Order id is null or blank ");
			throw new UserException("Order id is null or blank");
		}
	}

	private OrdersModel changeStatusAsPerTransactionState(Request request, String action, OrdersModel order) {
		if (action.equalsIgnoreCase(ON_CONFIRM)) {
			order.setIsServiceFulfilled(request.getMessage().getOrder().getState());
		} else
			order.setIsServiceFulfilled(INIT_STATE);
		return order;
	}

	private PaymentsModel extractPayments(Request request) {
        PaymentsModel paymentModel = new PaymentsModel();
        String paymentStatus=request.getMessage().getOrder().getPayment().getStatus();       
        paymentModel.setTransactionId(request.getMessage().getOrder().getPayment().getParams().getTransaction_id());
        paymentModel.setMethod(request.getMessage().getOrder().getPayment().getUri());
        paymentModel.setCurrency(request.getMessage().getOrder().getQuote().getPrice().getCurrency());
        paymentModel.setTransactionState(request.getMessage().getOrder().getPayment().getStatus());
        if(paymentStatus.equalsIgnoreCase("PAID"))
         {
        	paymentModel.setConsultationCharge(request.getMessage().getOrder().getQuote().getBreakup().get(0).getPrice().getValue());
        	paymentModel.setPhrHandlingFees(request.getMessage().getOrder().getQuote().getBreakup().get(3).getPrice().getValue());
        	paymentModel.setSgst(request.getMessage().getOrder().getQuote().getBreakup().get(2).getPrice().getValue());
        	paymentModel.setCgst(request.getMessage().getOrder().getQuote().getBreakup().get(1).getPrice().getValue());
         }
        return paymentModel;
    }

	private PaymentsModel checkForHealthIdIfNotThenTakeAbhaAddress_ForPayments(Request request, PaymentsModel p) {
		String abha = request.getMessage().getOrder().getCustomer().getId();
		if (abha == null || abha.isBlank() || abha.isEmpty())
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getCred());
		else
			p.setUserAbhaId(request.getMessage().getOrder().getCustomer().getId());
		return p;
	}

	public List<OrdersModel> getOrderDetailsByFilterParams(String hprid, String aType, Integer limit, String startDate,
			String endDate, String sort, String state) throws UserException {

		handleCustomErrorForMandatoryFields(aType, sort);

		List<OrdersModel> ordersFilteredList = null;
		ordersFilteredList = handleSorting(hprid, aType, sort, ordersFilteredList);
		ordersFilteredList = filterIfStartAndEndDateProvided(ordersFilteredList, startDate, endDate);
		ordersFilteredList = filterByState(state, ordersFilteredList);
		return handleLimitParameter(limit, ordersFilteredList);

	}

	public List<OrdersModel> getOrderDetailsByHprIdAndType(String hprid, String aType) {
		return orderRepo.findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(
				hprid, aType);
	}

	private List<OrdersModel> filterByState(String state, List<OrdersModel> ordersFilteredList) {
		if (null != state) {
			ordersFilteredList = ordersFilteredList.stream()
					.filter(res -> res.getIsServiceFulfilled().equalsIgnoreCase(state)).toList();

		}
		return ordersFilteredList;
	}

	private void handleCustomErrorForMandatoryFields(String aType, String sort) throws UserException {
		if (null == aType) {
			throw new UserException("Type cannot be null");
		}
		if (null == sort) {
			throw new UserException("sort cannot be null");
		}
	}

	private List<OrdersModel> handleLimitParameter(Integer limit, List<OrdersModel> ordersFilteredList) {
		if (limit != null && limit >= ordersFilteredList.size()) {
			return ordersFilteredList;
		} else if (limit != null)
			return ordersFilteredList.subList(0, limit);
		else
			return ordersFilteredList;
	}

	private List<OrdersModel> handleSorting(String hprid, String aType, String sort,
			List<OrdersModel> ordersFilteredList) {
		if (sort.equalsIgnoreCase("ASC")) {
			ordersFilteredList = orderRepo
					.findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(hprid,
							aType);
		} else if (sort.equalsIgnoreCase("DESC")) {
			ordersFilteredList = orderRepo
					.findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTimeDesc(
							hprid, aType);
		}
		return ordersFilteredList;
	}

	private List<OrdersModel> filterIfStartAndEndDateProvided(List<OrdersModel> ordersFilteredList, String startDate,
		      String endDate) {

		   if (null != startDate && null != endDate) {
		      ordersFilteredList = ordersFilteredList.stream().filter(res -> {
		         String serviceFulfillmentStartTime = res.getServiceFulfillmentStartTime();
		         String serviceFulFillmentEndTime = res.getServiceFulfillmentEndTime();
		         if(serviceFulFillmentEndTime.length() >= 19 && serviceFulfillmentStartTime.length() >= 19 ) {
		            return getLocalDateTimeFromString(serviceFulfillmentStartTime)
		                  .isAfter(getLocalDateTimeFromString(startDate))
		                  && getLocalDateTimeFromString(serviceFulFillmentEndTime)
		                  .isBefore(getLocalDateTimeFromString(endDate));
		         }
		         return false;


		      }).toList();

		      return ordersFilteredList;

		   }
		   return ordersFilteredList;
		}

	private LocalDateTime getLocalDateTimeFromString(String request) {
		DateTimeFormatter ofPattern = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss", Locale.ENGLISH);
		return LocalDateTime.parse(request, ofPattern);

	}

}