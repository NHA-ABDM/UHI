package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.dto.RequestSharedKeyDTO;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.IntermediatePatientAppointmentModel;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.models.SharedKeyModel;
import in.gov.abdm.uhi.hspa.models.opemMRSModels.appointment;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.util.function.Tuple2;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;

import static in.gov.abdm.uhi.hspa.service.CommonService.isFulfillmentTypeOrPaymentStatusCorrect;

@Service
public class ConfirmService implements IService {

    private static final String API_RESOURCE_PATIENT = "patient";
    private static final String API_RESOURCE_APPOINTMENT = "appointmentscheduling/appointment";
    private static final String API_RESOURCE_APPOINTMENT_TIMESLOT = "appointmentscheduling/timeslot";
    private static final String API_RESOURCE_APPOINTMENT_TYPE = "appointmentscheduling/appointmenttype?v=custom:uuid,name&q=";
    private static final Logger LOGGER = LogManager.getLogger(ConfirmService.class);
    final
    WebClient webClient;
    final
    ObjectMapper mapper;
    final
    CacheManager cacheManager;
    final
    SaveChatService chatIndb;
    final
    PaymentService paymentService;
    final
    CancelService cancelService;

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    @Autowired
    Crypt crypt;
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
    @Autowired
    WebClient euaWebClient;
    @Value("${spring.provider_id}")
    String PROVIDER_ID;


    @Value("${spring.gateway.publicKey}")
    String GATEWAY_PUBLIC_KEY;

    @Value("${spring.hspa.subsId}")
    String HSPA_SUBS_ID;

    @Value("${spring.hspa.privKey}")
    String HSPA_PRIV_KEY;

    @Value("${spring.hspa.pubKeyId}")
    String HSPA_PUBKEY_ID;



    @Autowired
    HspaUtility hspaUtility;

    public ConfirmService(WebClient webClient, ObjectMapper mapper, CacheManager cacheManager, SaveChatService chatIndb, PaymentService paymentService, CancelService cancelService) {
        this.webClient = webClient;
        this.mapper = mapper;
        this.cacheManager = cacheManager;
        this.chatIndb = chatIndb;
        this.paymentService = paymentService;
        this.cancelService = cancelService;
    }


    @Override
    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {
        Request objRequest = mapper.readValue(request, Request.class);
        getLocalDateTimeFromString(objRequest.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
        getLocalDateTimeFromString(objRequest.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
        String typeFulfillment = objRequest.getMessage().getOrder().getFulfillment().getType();
        LOGGER.info("Processing::Confirm::Request:: {} .. Message Id is {}", request, getMessageId(objRequest));

        if(Boolean.parseBoolean(isHeaderEnabled)) {
            return processConfirmWithHeaderVerification(request, headers, objRequest, typeFulfillment);
        }
        else{
            return processConfirm(request, headers, typeFulfillment, objRequest);
        }
    }

    private Mono<Response> processConfirmWithHeaderVerification(String request, Map<String, String> headers, Request objRequest, String typeFulfillment) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        HspaUtility.checkAuthHeader(headers, objRequest);
        Map<String, String> keyIdMap = hspaUtility.getKeyIdMapFromHeaders(headers, objRequest);
        Mono<List<Subscriber>> subscriberDetails = hspaUtility.getSubscriberDetailsOfEua(objRequest, keyIdMap.get("subscriber_id"),keyIdMap.get("pub_key_id"));

        return subscriberDetails.flatMap(lookupRes -> {
            if (!lookupRes.isEmpty()) {
                try {
                    if (hspaUtility.verifyHeaders(objRequest, headers, GlobalConstants.AUTHORIZATION.toLowerCase(), lookupRes.get(0).getEncr_public_key(), request)) {
                        return processConfirm(request, headers, typeFulfillment, objRequest);
                    } else {
                        LOGGER.error("{} | ConfirmService::processor::Header verification failed", objRequest.getContext().getMessageId());
                        return Mono.error(new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage()));
                    }
                } catch (JsonProcessingException | NoSuchAlgorithmException | NoSuchProviderException |
                         InvalidKeyException | SignatureException | InvalidKeySpecException e) {
                    LOGGER.error("{} | {}::processor::error::{}", objRequest.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                    return Mono.error(new InvalidKeyException(GatewayError.INVALID_KEY.getMessage()));
                } catch (Exception e) {
                    LOGGER.error("{} | {}::processor::error::{}", objRequest.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                    return Mono.error(new HspaException(GatewayError.INTERNAL_SERVER_ERROR.getMessage()));
                }
            }
            return Mono.just(CommonService.generateAck());
        });
    }

    private Mono<Response> processConfirm(String request, Map<String, String> headers, String typeFulfillment, Request finalObjRequest) {
        if (isFulfillmentTypeOrPaymentStatusCorrect(typeFulfillment, ConstantsUtils.TELECONSULTATION, ConstantsUtils.PHYSICAL_CONSULTATION)) {
            run(finalObjRequest, request, headers);
        }
        return Mono.just(CommonService.generateAck());
    }

    @Override
    public Mono<String> run(Request request, String s) throws Exception {
        return null;
    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception {
        return null;
    }


    public Mono<String> run(Request request, String s, Map<String, String> headers) {

        String paymentStatus = request.getMessage().getOrder().getPayment().getStatus();
        Mono<String> response = Mono.empty();

        if (isFulfillmentTypeOrPaymentStatusCorrect(paymentStatus, ConstantsUtils.PAYMENT_STATUS_PAID, ConstantsUtils.PAYMENT_STATUS_FREE)) {
            getPatientDetails(request).zipWith(getAllAppointmentTypes(request))
                    .flatMap(result -> getPatinetandAppointment(result, request))
                    .flatMap(this::createAppointment)
                    .flatMap(result -> callOnConfirm(result, request, headers))
                    .flatMap(log -> logResponse(log, request))
                    .subscribe();
        } else {

            LOGGER.info("Processing::Search::Run::Not Paid! {}.. Message Id is {}", request, getMessageId(request));
            callOnConfirm("", request, headers);
        }


        return response;
    }

    private Mono<String> getPatientDetails(Request request) {

        String abha = request.getMessage().getOrder().getCustomer().getId();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PATIENT;
        String searchPatient = "?v=custom:uuid&q=" + abha;

        return webClient.get()
                .uri(searchEndPoint + searchPatient)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    public Mono<String> getAllAppointmentTypes(Request request) {

        String serviceType = request.getMessage().getOrder().getFulfillment().getType();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT_TYPE + serviceType;

        return webClient.get()
                .uri(searchEndPoint)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    private Mono<List<IntermediatePatientAppointmentModel>> getPatinetandAppointment(Tuple2 result, Request request) {


        List<IntermediatePatientAppointmentModel> patientModel = new ArrayList<>();

        try {

            patientModel = IntermediateBuilderUtils.BuildIntermediatePatientAppoitmentObj(result.getT2().toString(), result.getT1().toString(), request.getMessage().getOrder());

            LOGGER.info("{} | Generated patientModel is {}",request.getContext().getMessageId(), patientModel);
        } catch (Exception ex) {
            LOGGER.error("Select service Get Provider Id::error::onErrorResume:: {} .. Message Id is {}", ex, getMessageId(request));
        }
        return Mono.just(patientModel);
    }

    private String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
    }

    private boolean checkIfSlotAvailable(Request request) {
        AtomicReference<Boolean> isBooked = new AtomicReference<>(true);
        Cache cache = cacheManager.getCache("slotCache");
        Mono<String> existingAppointment = checkValidAppointment(request);
        existingAppointment.flatMap(result -> {
                    if (result.contains("\"countOfAppointments\": 1")) {
                        isBooked.set(false);
                    } else if (cache != null && cache.get(request.getMessage().getOrder().getFulfillment().getId()) != null) {
                        isBooked.set(false);
                    }

                    return Mono.empty();
                })
                .subscribe();
        return isBooked.get();
    }

    private Mono<String> checkValidAppointment(Request request) {

        String appointmentSlot = request.getMessage().getOrder().getFulfillment().getId();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT_TIMESLOT;
        String searchAppointment = "/" + appointmentSlot;

        return webClient.get()
                .uri(searchEndPoint + searchAppointment)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    private Mono<String> createAppointment(List<IntermediatePatientAppointmentModel> collection) {
        if (!collection.isEmpty()) {
            appointment appointment = IntermediateBuilderUtils.BuildAppointmentModel(collection.get(0));

            String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT;
            return webClient.post()
                    .uri(searchEndPoint)
                    .body(BodyInserters.fromValue(appointment))
                    .exchangeToMono(clientResponse ->
                            clientResponse.bodyToMono(String.class)).log();
        }
        return Mono.just("");
    }

    private Mono<String> callOnConfirm(String result, Request request, Map<String, String> headers) {

        String uuid = "";
        request.getContext().setAction(ConstantsUtils.ON_CONFIRM);
        uuid = setOrderStatus(result, request, uuid);

        setProviderUrl(request);
        String patient = request.getMessage().getOrder().getCustomer().getId();
        String doctor = request.getMessage().getOrder().getFulfillment().getAgent().getId();

        Optional<Map<String, String>> fulfillmentTagsMapOptional = Optional.ofNullable(request.getMessage().getOrder().getFulfillment().getTags());

        if (fulfillmentTagsMapOptional.isPresent()) {
            Map<String, String> map = fulfillmentTagsMapOptional.get();
            String key = map.get(ConstantsUtils.ABDM_GOV_IN_PATIENT_KEY);
            boolean saveKeyToDBIfNotNull = key != null;
            savePatientKeyToDb(patient, key, saveKeyToDBIfNotNull);
            List<SharedKeyModel> doctorKey = chatIndb.getSharedKeyDetails(doctor);
            setDoctorsKeyToResponse(request, doctorKey);
        }

        boolean isResultContainsAppointmentId = result.contains("uuid");
            try {
                Mono<OrdersModel> ordersModelMono = paymentService.saveDataInDb(uuid, request, ConstantsUtils.ON_CONFIRM);
                return ordersModelMono.flatMap(ordersModel -> {
                    if(null == request.getMessage().getOrder().getFulfillment().getTags()) {
                        request.getMessage().getOrder().getFulfillment().setTags(new HashMap<>());
                    }
                    request.getMessage().getOrder().getFulfillment().getTags().put(GlobalConstants.ABDM_GOV_IN_TELECONSULTATION_URI, ordersModel.getPatientTeleconsultationUri());
                    LOGGER.info("Request sent to on_confirm {} .. Message Id is {}", request, getMessageId(request));

                    try {
                        return callOnConfirmWebClient(request);
                    } catch (JsonProcessingException | NoSuchAlgorithmException e) {
                        return Mono.error(new HspaException(e.getMessage()));
                    } catch (NoSuchProviderException | InvalidKeySpecException e) {
                        return Mono.error(new InvalidKeyException(e.getMessage()));
                    }
                });
            } catch (JsonProcessingException | UserException e) {
                LOGGER.error(e.getMessage());
            }
        return Mono.empty();
    }

    private Mono<String> callOnConfirmWebClient(Request request) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {

        String onConfirmResponse = mapper.writeValueAsString(request);
        return euaWebClient.post()
                .uri(request.getContext().getConsumerUri() + "/on_confirm")
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onConfirmResponse, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onConfirmResponse))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    LOGGER.error("confirm Service call on confirm:: {} .. Message Id is {}", error, getMessageId(request));
                    return Mono.error(new HspaException(error.getLocalizedMessage()));
                });

    }

    private void setDoctorsKeyToResponse(Request request, List<SharedKeyModel> doctorKey) {
        if (!doctorKey.isEmpty()) {
            SharedKeyModel keydetails = doctorKey.get(0);
            request.getMessage().getOrder().getFulfillment().getTags().put("@abdm/gov.in/doctors_key", keydetails.getPublicKey());
        }
    }

    private void savePatientKeyToDb(String patient, String key, boolean saveKeyToDBIfNotNull) {
        if (saveKeyToDBIfNotNull) {
            RequestSharedKeyDTO rpk = new RequestSharedKeyDTO();
            rpk.setUserName(patient);
            rpk.setPublicKey(key);
            chatIndb.saveSharedKey(rpk);
        }
    }

    private void setProviderUrl(Request request) {
        request.getContext().setProviderUri(PROVIDER_URI);
        request.getContext().setProviderId(PROVIDER_ID);

    }

    private String setOrderStatus(String result, Request request, String uuid) {
        if (!checkIfSlotAvailable(request)) {
            request.getMessage().getOrder().setState("FAILED");
        } else if (result.contains("uuid")) {
            request.getMessage().getOrder().setState("CONFIRMED");
            uuid = IntermediateBuilderUtils.getUUID(result);
        } else {
            request.getMessage().getOrder().setState("FAILED");
        }
        return uuid;
    }

    public Mono<String> logResponse(String result, Request request) {

        LOGGER.info("OnConfirm::Log::Response:: {} \n Message Id is {}", result, getMessageId(request));

        return Mono.just(result);
    }

    @Override
    public boolean updateOrderStatus(String status, String orderId) throws UserException {
        return false;
    }

    private LocalDateTime getLocalDateTimeFromString(String request) {
        return LocalDateTime.parse(request, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

}

