package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.opemMRSModels.patient;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static in.gov.abdm.uhi.hspa.service.CommonService.isFulfillmentTypeOrPaymentStatusCorrect;

@Service
public class InitService implements IService {

    private static final String API_RESOURCE_PATIENT = "patient";
    private static final String API_RESOURCE_PROVIDER = "provider";
    private static final Logger LOGGER = LogManager.getLogger(InitService.class);
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    @Value("${spring.openmrs_api}")
    String OPENMRS_API;
    @Value("${spring.openmrs_username}")
    String OPENMRS_USERNAME;
    @Value("${spring.openmrs_password}")
    String OPENMRS_PASSWORD;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.provider_id}")
    String PROVIDER_ID;

    final
    WebClient euaWebClient;

    final
    WebClient webClient;

    final
    CacheManager cacheManager;

    final
    PaymentService paymentService;

    final
    HspaUtility hspaUtility;

    final
    ObjectMapper objectMapper;

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;


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

    public InitService(WebClient euaWebClient, WebClient webClient, CacheManager cacheManager, PaymentService paymentService, HspaUtility hspaUtility, ObjectMapper objectMapper) {
        this.euaWebClient = euaWebClient;
        this.webClient = webClient;
        this.cacheManager = cacheManager;
        this.paymentService = paymentService;
        this.hspaUtility = hspaUtility;
        this.objectMapper = objectMapper;
    }

    @Override
    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {
        Request objRequest;
        objRequest = objectMapper.readValue(request, Request.class);
        Request finalObjRequest = objRequest;


        getLocalDateTimeFromString(finalObjRequest.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
        getLocalDateTimeFromString(finalObjRequest.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
        String orderId = UniqueOrderIdGeneratorService.generate(LocalTime.now().toString());
        objRequest.getMessage().getOrder().setId(orderId);
        LOGGER.info("Order id------- {}", orderId);
        String typeFulfillment = objRequest.getMessage().getOrder().getFulfillment().getType();
        LOGGER.info("Processing::Init::Request:: {}.. Message Id is {}", objRequest, getMessageId(objRequest));


        if(Boolean.parseBoolean(isHeaderEnabled)) {
            return processInitWithHeaderVerification(request, headers, objRequest, finalObjRequest, typeFulfillment);
        }
        else{
            return processInit(objRequest,typeFulfillment);
        }
    }

    private Mono<Response> processInitWithHeaderVerification(String request, Map<String, String> headers, Request objRequest, Request finalObjRequest, String typeFulfillment) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        HspaUtility.checkAuthHeader(headers, objRequest);
        Map<String, String> keyIdMap = hspaUtility.getKeyIdMapFromHeaders(headers, objRequest);
        Mono<List<Subscriber>> subscriberDetails = hspaUtility.getSubscriberDetailsOfEua(objRequest, keyIdMap.get("subscriber_id"),keyIdMap.get("pub_key_id"));

        return subscriberDetails.flatMap(lookupRes -> {
            if (!lookupRes.isEmpty()) {
                try {
                    if (hspaUtility.verifyHeaders(objRequest, headers, GlobalConstants.AUTHORIZATION.toLowerCase(), lookupRes.get(0).getEncr_public_key(), request)) {
                        return processInit(finalObjRequest, typeFulfillment);
                    } else {
                        LOGGER.error("{} | InitService::processor::Header verification failed", objRequest.getContext().getMessageId());
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

    private Mono<Response> processInit(Request finalObjRequest, String typeFulfillment) {
        if (isFulfillmentTypeOrPaymentStatusCorrect(typeFulfillment, ConstantsUtils.TELECONSULTATION, ConstantsUtils.PHYSICAL_CONSULTATION)) {
            findPatient(finalObjRequest)
                    .flatMap(result -> createPatient(result, finalObjRequest))
                    .flatMap(result -> createResponse(result, finalObjRequest))
                    .flatMap(result -> {
                        try {
                            return callOnInit(result);
                        } catch (JsonProcessingException | NoSuchAlgorithmException e) {
                            return Mono.error(new HspaException(e.getMessage()));
                        } catch (NoSuchProviderException | InvalidKeySpecException | UserException e) {
                            return Mono.error(new InvalidKeyException(e.getMessage()));
                        }
                    })
                    .flatMap(log -> logResponse(log, finalObjRequest))
                    .subscribe();
        } else {
            return Mono.just(Response.builder().build());
        }
        return Mono.just(CommonService.generateAck());
    }

    @Override
    public Mono<String> run(Request request, String s) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PROVIDER;

        Map<String, String> searchParams = IntermediateBuilderUtils.BuildSearchParametersOrder(request);
        String searchString = buildSearchString(searchParams);
        return webClient.get()
                .uri(searchEndPoint + searchString)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception {
        return null;
    }

    private Mono<Request> createResponse(String result, Request request) {

        IntermediateBuilderUtils.BuildIntermediatePatient(result);
        Request retRequest = ProtocolBuilderUtils.BuildIntitialization(request);

        return Mono.just(retRequest);
    }

    private void putCache() {
        cacheManager.getCache("slotCache");
    }


    private Mono<String> createPatient(String exisiting, Request request) {

        putCache();

        if (exisiting.contains("uuid")) {
            return Mono.just(exisiting);
        }

        patient patient = IntermediateBuilderUtils.BuildPatientModel(request.getMessage().getOrder());

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PATIENT;


        return webClient.post()
                .uri(searchEndPoint)
                .body(BodyInserters.fromValue(patient))
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }


    Mono<String> findPatient(Request request) {

        String abha = request.getMessage().getOrder().getCustomer().getId();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PATIENT;
        String searchPatient = "?v=full&q=" + abha;
        return webClient.get()
                .uri(searchEndPoint + searchPatient)
                .headers(headers -> headers.setBasicAuth(OPENMRS_USERNAME, OPENMRS_PASSWORD))
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    private String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
    }

    private Mono<String> callOnInit(Request request) throws UserException, JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        request.getContext().setAction("on_init");
        request.getContext().setProviderId(PROVIDER_ID);
        request.getContext().setProviderUri(PROVIDER_URI);
        paymentService.saveDataInDb(null, request, ConstantsUtils.ON_INIT);


        String onInitResponse = objectMapper.writeValueAsString(request);
        LOGGER.info("{} | OnInit response {}",request.getContext().getMessageId(), onInitResponse);



        return euaWebClient.post()
                .uri(request.getContext().getConsumerUri() + "/on_init")
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onInitResponse, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onInitResponse))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    LOGGER.error("Init Service call on init:: {} .. Message Id {}", error, getMessageId(request));
                    return Mono.error(new HspaException(error.getMessage()));
                });
    }

    private String buildSearchString(Map<String, String> params) {
        String searchString = "?v=custom:uuid,providerId,identifier,person:(display)&q=";
        String value = "";
        if (params.get(ConstantsUtils.HPRID) == null || Objects.equals(params.get(ConstantsUtils.HPRID), "")) {
            value = params.getOrDefault("name", "");
        } else {
            value = params.getOrDefault(ConstantsUtils.HPRID, "");
        }
        return searchString + value;
    }

    @Override
    public Mono<String> logResponse(String result, Request request) {

        LOGGER.info("OnInit::Log::Response:: {} \n Message Id is {}", result, getMessageId(request));
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
