package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.dto.CancelRequestDTO;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import in.gov.abdm.uhi.hspa.utils.Crypt;
import in.gov.abdm.uhi.hspa.utils.HspaUtility;
import in.gov.abdm.uhi.hspa.utils.GlobalConstants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Service
public class CancelService implements IService {
    private static final String API_RESOURCE_APPOINTMENT = "appointmentscheduling/appointment";


    private static final Logger LOGGER = LogManager.getLogger(CancelService.class);
    final
    WebClient webClient;
    final
    ObjectMapper mapper;
    final
    PaymentService paymentService;
    final
    CacheManager cacheManager;
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
    @Value("${spring.provider_id}")
    String PROVIDER_ID;
    @Autowired
    WebClient euaWebClient;
    @Value("${spring.notificationService.baseUrl}")
    private String NOTIFICATION_SERVICE_BASE_URL;

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    @Autowired
    HspaUtility hspaUtility;


    @Value("${spring.gateway.publicKey}")
    String GATEWAY_PUBLIC_KEY;

    @Value("${spring.hspa.subsId}")
    String HSPA_SUBS_ID;

    @Value("${spring.hspa.privKey}")
    String HSPA_PRIV_KEY;

    @Value("${spring.hspa.pubKeyId}")
    String HSPA_PUBKEY_ID;

    @Autowired
    Crypt crypt;

    @Autowired
    ObjectMapper objectMapper;

    public CancelService(WebClient webClient, ObjectMapper mapper, PaymentService paymentService, CacheManager cacheManager) {
        this.webClient = webClient;
        this.mapper = mapper;
        this.paymentService = paymentService;
        this.cacheManager = cacheManager;
    }

    private static Mono<String> generateNackString() {
        Mono<String> monores = null;
        try {
            MessageAck msz = MessageAck.builder().build();
            Response res = Response.builder().build();
            Ack ack = Ack.builder().build();
            ack.setStatus("NACK");
            msz.setAck(ack);
            Error err = new Error();
            err.setMessage("Order Not found in db");
            err.setType("Search");
            res.setError(err);
            res.setMessage(msz);
            ObjectMapper ob = new ObjectMapper();

            monores = Mono.just(ob.writeValueAsString(res));
        } catch (JsonProcessingException e) {
            LOGGER.error("Parsing error in nack");

        }
        return monores;

    }

    @Override
    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {
        Request objRequest = mapper.readValue(request, Request.class);
             processCancel(request, headers, objRequest);
             return Mono.just(CommonService.generateAck());
    }

    private Mono<Response> processCancelWithHeaderVerification(String request, Map<String, String> headers, Request objRequest) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        HspaUtility.checkAuthHeader(headers, objRequest);
        Map<String, String> keyIdMap = hspaUtility.getKeyIdMapFromHeaders(headers, objRequest);
        Mono<List<Subscriber>> subscriberDetails = hspaUtility.getSubscriberDetailsOfEua(objRequest, keyIdMap.get("subscriber_id"),keyIdMap.get("pub_key_id"));

        return subscriberDetails.flatMap(lookupRes -> {
            if (!lookupRes.isEmpty()) {
                try {
                    if (hspaUtility.verifyHeaders(objRequest, headers, GlobalConstants.AUTHORIZATION.toLowerCase(), lookupRes.get(0).getEncr_public_key(), request)) {
                        processCancel(request, headers, objRequest);
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

    private void processCancel(String request, Map<String, String> headers, Request objRequest) {
        try {
            LOGGER.info("Processing::Cancel::Request:: {}, Message Id is {}", request, getMessageId(objRequest));
            run(objRequest, request, headers).subscribe();
        } catch (Exception ex) {
            LOGGER.error("Cancel Service process::error::onErrorResume:: {}, Message Id is {}", ex, getMessageId(objRequest));
        }
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

        String orderId = request.getMessage().getOrder().getId();
        Map<String, String> fulfillmentTagsMap = request.getMessage().getOrder().getFulfillment().getTags();

        String key = fulfillmentTagsMap.get(GlobalConstants.ABDM_GOV_IN_CANCELLEDBY);
        String appointmentID = "";
        List<OrdersModel> orders;
        if (key.equalsIgnoreCase(ConstantsUtils.PATIENT)) {
            orders = paymentService.getOrderDetailsByOrderId(orderId);
            if (!orders.isEmpty()) {
                OrdersModel order = orders.get(0);
                appointmentID = order.getAppointmentId();
            } else {
                LOGGER.info("Order Not found in db {}, .. Message Id is {}", request, getMessageId(request));
                return generateNackString();
            }
        } else if (key.contains("doctor")) {
            appointmentID = orderId;
        }


        final String finalappointmentId = appointmentID;
        return getAppointmentDetails(appointmentID)
                .flatMap(result -> cancelAppointment(result, finalappointmentId))
                .flatMap(result -> callOnCancel(result, request))
                .flatMap(result -> cancelSecondOrder(request, result, headers))
                .flatMap(reulut -> purgeAppointment(finalappointmentId, request))
                .flatMap(res-> {
                    try {
                        return callOnCancelWebClient(request);
                    } catch (JsonProcessingException | NoSuchAlgorithmException e) {
                        return Mono.error(new HspaException(e.getMessage()));
                    } catch (NoSuchProviderException | InvalidKeySpecException e) {
                        return Mono.error(new InvalidKeyException(e.getMessage()));
                    }
                });
    }


    private Mono<String> getAppointmentDetails(String appointmentId) {
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT + "/" + appointmentId;
        String searchView = "?v=custom:status,timeSlot:(startDate,endDate)";

        return webClient.get()
                .uri(searchEndPoint + searchView)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }


    private Mono<String> cancelAppointment(String result, String appointmentId) {

        if (result.contains("SCHEDULED")) {

            String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT + "/" + appointmentId;

            CancelRequestDTO cancel = new CancelRequestDTO();
            cancel.setStatus(ConstantsUtils.CANCELLED);
            cancel.setCancelReason("Canceled ");
            return webClient.post()
                    .uri(searchEndPoint)
                    .body(BodyInserters.fromValue(cancel))
                    .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
        }
        return Mono.just("No Scheduled appointments found");
    }


    private Mono<OrdersModel> callOnCancel(String result, Request request) {
        OrdersModel order = null;
        if (result.contains("uuid")) {
            request.getContext().setAction("on_cancel");
            request.getMessage().getOrder().setState("CANCELLED");


            String orderId = request.getMessage().getOrder().getId();
            Map<String, String> fulfillmentTagsMap = request.getMessage().getOrder().getFulfillment().getTags();
            String key = fulfillmentTagsMap.get(GlobalConstants.ABDM_GOV_IN_CANCELLEDBY);
            List<OrdersModel> orders = null;
            orders = getOrdersBasedOnPersonCancelling(orderId, key, orders);
            request.getContext().setProviderUri(PROVIDER_URI);
            order = callNotificatonService(request, order, key, orders);
            return Mono.just(order);

        } else {
            LOGGER.error("{} | Error while cancelling appointment \n Message is {}", getMessageId(request), result);
            return Mono.error(new HspaException("Error cancelling appointment"));
        }
    }


    private Mono<String> cancelSecondOrder(Request request, OrdersModel order, Map<String,String> headers) {
        Map<String, String> fulfillmentTagsMap = request.getMessage().getOrder().getFulfillment().getTags();
        String key = fulfillmentTagsMap.get(GlobalConstants.ABDM_GOV_IN_CANCELLEDBY);
        boolean isDoctor = key.contains("doctor");
        if (isDoctor) {

            List<OrdersModel> od = paymentService.getOrderDetailsByTransactionId(order.getTransId());
            String ordId = order.getOrderId();
            List<OrdersModel> otherDrOrder = od
                    .stream()
                    .filter(c -> !(c.getOrderId().equalsIgnoreCase(ordId)) && c.getIsServiceFulfilled().equalsIgnoreCase(ConstantsUtils.CONFIRMED))
                    .toList();
            if (!otherDrOrder.isEmpty()) {

                OrdersModel grporder1 = otherDrOrder.get(0);

                request.getMessage().getOrder().setId(grporder1.getOrderId());
                request.getMessage().getOrder().setState(ConstantsUtils.CANCELLED);
                request.getMessage().getOrder().getFulfillment().getTags().put(GlobalConstants.ABDM_GOV_IN_CANCELLEDBY, ConstantsUtils.PATIENT);
                request.getContext().setAction(ConstantsUtils.CANCEL);
                try {
                    processor(mapper.writeValueAsString(request),headers);
                } catch (Exception e) {

                    LOGGER.error(e.getMessage());
                }

            }
        }
        return Mono.just("request");
    }


    private Mono<String> callOnCancelWebClient(Request request) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {
        Mono<String> oncancel;
        request.getContext().setProviderId(PROVIDER_ID);
        request.getContext().setProviderUri(PROVIDER_URI);

        String onCancelResponse = objectMapper.writeValueAsString(request);


        oncancel = euaWebClient.post()
                .uri(request.getContext().getConsumerUri() + "/on_cancel")
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onCancelResponse, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onCancelResponse))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Cancel Service call on cancel:: {} \n Message Id is {}", error, getMessageId(request));
                    return Mono.error(new HspaException(error.getMessage()));
                });
        return oncancel;
    }


    private OrdersModel callNotificatonService(Request request, OrdersModel order, String key,
                                               List<OrdersModel> orders) {
        if (!(orders.isEmpty())) {
            order = orders.get(0);
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
            } else {
                LOGGER.error("CancelService :: callOnCancel :: error .. Orders are null.. Message Id is {}", getMessageId(request));
            }
        }
        return order;
    }


    private List<OrdersModel> getOrdersBasedOnPersonCancelling(String orderId, String key, List<OrdersModel> orders) {
        if (key.equalsIgnoreCase(ConstantsUtils.PATIENT)) {
            orders = paymentService.getOrderDetailsByOrderId(orderId);
        } else if (key.contains("doctor")) {
            orders = paymentService.getOrderDetailsByAppointmentId(orderId);
        }
        return orders;
    }

    private String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
    }

    private Mono<String> purgeAppointment(String appointmentId, Request request) {
        try {
            String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT + "/" + appointmentId;
            String additionalParam = "?!purge&reason=NA";
            webClient.delete()
                    .uri(searchEndPoint + additionalParam)
                    .retrieve().bodyToMono(String.class).subscribe();

            return Mono.just("success");
        } catch (Exception ex) {

            LOGGER.error("Error purging appointment {}. Requester message id is {}", ex.getMessage(), request.getContext().getMessageId());
        }
        return Mono.just("error");
    }

    public Mono<String> logResponse(String result, Request request) {
        LOGGER.info("OnCancel::Log::Response:: {}, \n Message Id is {}", result, getMessageId(request));
        return Mono.just(result);
    }

    @Override
    public boolean updateOrderStatus(String status, String orderId) throws UserException {
        return false;
    }

}
