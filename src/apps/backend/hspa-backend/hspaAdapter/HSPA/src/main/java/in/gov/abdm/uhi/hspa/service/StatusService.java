package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.dto.UpdateOrderDTO;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.repo.OrderRepository;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import in.gov.abdm.uhi.hspa.utils.Crypt;
import in.gov.abdm.uhi.hspa.utils.HspaUtility;
import in.gov.abdm.uhi.hspa.utils.GlobalConstants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
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
import java.util.Objects;

@Service
public class StatusService implements IService {


    private static final Logger LOGGER = LogManager.getLogger(StatusService.class);
    final
    WebClient webClient;
    final
    ObjectMapper mapper;
    final OrderRepository orderRepository;
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

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    final
    HspaUtility hspaUtility;

    final
    ObjectMapper objectMapper;

    @Value("${spring.provider_id}")
    String PROVIDER_ID;

    final
    WebClient euaWebClient;

    @Value("${spring.gateway.publicKey}")
    String GATEWAY_PUBLIC_KEY;

    @Value("${spring.hspa.subsId}")
    String HSPA_SUBS_ID;

    @Value("${spring.hspa.privKey}")
    String HSPA_PRIV_KEY;

    @Value("${spring.hspa.pubKeyId}")
    String HSPA_PUBKEY_ID;

    final
    Crypt crypt;
    public StatusService(WebClient webClient, ObjectMapper mapper, OrderRepository orderRepository, HspaUtility hspaUtility, ObjectMapper objectMapper, @Qualifier("normalWebClient") WebClient euaWebClient, Crypt crypt) {
        this.webClient = webClient;
        this.mapper = mapper;
        this.orderRepository = orderRepository;
        this.hspaUtility = hspaUtility;
        this.objectMapper = objectMapper;
        this.euaWebClient = euaWebClient;
        this.crypt = crypt;
    }

    private static Response generateAck() {

        MessageAck msz = MessageAck.builder().build();
        Response res = Response.builder().build();
        Ack ack = Ack.builder().build();
        ack.setStatus("ACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new in.gov.abdm.uhi.common.dto.Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }


    @Override
    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {

        Request objRequest = objectMapper.readValue(request, Request.class);
        if(Boolean.parseBoolean(isHeaderEnabled)){
            HspaUtility.checkAuthHeader(headers,objRequest);
            Map<String, String> keyIdMap = hspaUtility.getKeyIdMapFromHeaders(headers, objRequest);
            Mono<List<Subscriber>> subscriberDetails = hspaUtility.getSubscriberDetailsOfEua(objRequest, keyIdMap.get("subscriber_id"),keyIdMap.get("pub_key_id"));

            return subscriberDetails.flatMap(lookupRes -> {
                LOGGER.info("Processing::Status::Request:: {}", request);
                Response ack = generateAck();
                if (!lookupRes.isEmpty()) {
                    try {
                        if (hspaUtility.verifyHeaders(objRequest, headers, GlobalConstants.AUTHORIZATION.toLowerCase(), lookupRes.get(0).getEncr_public_key(), request)) {
                            return processStatusCall(request, objRequest);
                        }
                        else {
                            LOGGER.error("{} | MessageService::processor::Header verification failed",objRequest.getContext().getMessageId());
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
                return Mono.just(ack);
            });
        }
        else{
            return processStatusCall(request, objRequest);
        }
    }

    private Mono<Response> processStatusCall(String request, Request objRequest) {
        logMessageId(objRequest);
        run(objRequest, request);
        return Mono.just(generateAck());
    }

    @Override
    public Mono<String> run(Request request, String s) {
        Mono<String> response = Mono.empty();
        Objects.requireNonNull(getAppointmentStatus(request))
                .filter(Objects::nonNull)
                .flatMap(this::transformObject)
                .flatMap(result -> {
                    try {
                        return callOnStatus(result);
                    } catch (JsonProcessingException | NoSuchAlgorithmException e) {
            return Mono.error(new HspaException(e.getMessage()));
        } catch (NoSuchProviderException | InvalidKeySpecException e) {
            return Mono.error(new InvalidKeyException(e.getMessage()));
        }
                })
                .subscribe();


        return response;
    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception {
        return null;
    }

    private Mono<Request> transformObject(OrdersModel appointmentStatus) {

        try {
            Request onStatusResponse = mapper.readValue(appointmentStatus.getMessage(), Request.class);
            onStatusResponse.getContext().setAction("on_status");
            onStatusResponse.getMessage().getOrder().setState(appointmentStatus.getIsServiceFulfilled());
            return Mono.just(onStatusResponse);
        } catch (JsonProcessingException e) {
            LOGGER.error("Error parsing request. Please try again");
            return Mono.error(new HspaException(e.getMessage()));
        }
    }

    private void logMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
    }

    private Mono<OrdersModel> getAppointmentStatus(Request request) {
        String orderIdFromRequest = request.getMessage().getOrder().getId();
        List<OrdersModel> orderRecord = orderRepository.findByOrderId(orderIdFromRequest);
        if (orderRecord != null && !orderRecord.isEmpty()) {
            return Mono.just(orderRecord.get(0));
        } else {
            return null;
        }
    }

    private Mono<String> callOnStatus(Request request) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        String onStatusRequestString = mapper.writeValueAsString(request);
        LOGGER.info("{} | onStatus response {}", request.getContext().getAction(), onStatusRequestString);

        String consumerUri = request.getContext().getConsumerUri();
        return euaWebClient.post()
                .uri(consumerUri + "/on_status")
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onStatusRequestString, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onStatusRequestString))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    LOGGER.error("Error in status API::error::onErrorResume:: {}, {}", error, null);
                    return Mono.error(new HspaException(error.getLocalizedMessage()));
                });
    }

    @Override
    public Mono<String> logResponse(String result, Request request) {
        LOGGER.info("OnConfirm::Log::Response:: {}", result);
        return Mono.just(result);
    }


    @Override
    public boolean  updateOrderStatus(String status, String orderId) throws UserException, JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        List<OrdersModel> byOrderId = orderRepository.findByOrderId(orderId);
        if(null != byOrderId && !byOrderId.isEmpty()) {
            OrdersModel ordersModel = byOrderId.get(0);
            UpdateOrderDTO updateOrderDTO = mapper.readValue(status, UpdateOrderDTO.class);
            String orderStatus = updateOrderDTO.getStatus();
            if(null!= orderStatus) {
                switch (orderStatus) {
                    case "CONFIRMED", "CANCELLED", "FAILED", "PROCESSING", "COMPLETED" -> {
                        ordersModel.setIsServiceFulfilled(orderStatus);
                        callStatusApiEua(ordersModel);
                    }
                    default -> throw new HspaException("Invalid Status");
                }
                OrdersModel resultUpdateStatus = orderRepository.save(ordersModel);
                return null != resultUpdateStatus.getOrderId();
            }
        }
        else
            throw new HspaException("Invalid OrderId. Cannot find order");

        return false;
    }

    private void callStatusApiEua(OrdersModel ordersModel) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        Request statusRequest = mapper.readValue(ordersModel.getMessage(), Request.class);
        statusRequest.getContext().setAction("on_status");
        statusRequest.getMessage().getOrder().setState(ordersModel.getIsServiceFulfilled());
        callOnStatus(statusRequest).subscribe();
    }
}
