package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.IntermediatePatientModel;
import in.gov.abdm.uhi.hspa.models.opemMRSModels.patient;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import in.gov.abdm.uhi.hspa.utils.IntermediateBuilderUtils;
import in.gov.abdm.uhi.hspa.utils.ProtocolBuilderUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
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

    @Autowired
    WebClient euaWebClient;

    @Autowired
    WebClient webClient;

    @Autowired
    CacheManager cacheManager;

    @Autowired
    PaymentService paymentService;

    private static Response generateAck() {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("ACK");
        msz.setAck(ack);
        Error err = new Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    @Override
    public Mono<Response> processor(String request) throws UserException {
        Request objRequest = null;
        Response ack = generateAck();


        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            Request finalObjRequest = objRequest;

            getLocalDateTimeFromString(finalObjRequest.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
            getLocalDateTimeFromString(finalObjRequest.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
            String orderId = UniqueOrderIdGeneratorService.generate(LocalTime.now().toString());
            objRequest.getMessage().getOrder().setId(orderId);
            LOGGER.info("Order id------- {}", orderId);
            ////TODO: If provider not found donot add patient
            String typeFulfillment = objRequest.getMessage().getOrder().getFulfillment().getType();
            LOGGER.info("Processing::Init::Request:: {}.. Message Id is {}", objRequest, getMessageId(objRequest));

            if (isFulfillmentTypeOrPaymentStatusCorrect(typeFulfillment, ConstantsUtils.TELECONSULTATION, ConstantsUtils.PHYSICAL_CONSULTATION)) {
                findPatient(finalObjRequest)
                        .flatMap(result -> createPatient(result, finalObjRequest))
                        .flatMap(result -> createResponse(result, finalObjRequest))
                        .flatMap(this::callOnInit)
                        .flatMap(log -> logResponse(log, finalObjRequest))
                        .subscribe();
            } else {
                return Mono.just(new Response());
            }


        } catch (Exception ex) {
            LOGGER.error("Init Service process::error::onErrorResume:: {} .. Message Id is {}", ex, getMessageId(objRequest));
            ack = CommonService.setMessageidAndTxnIdInNack(objRequest, ex);
        }

        return Mono.just(ack);
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

    private Mono<Request> createResponse(String result, Request request) {

        IntermediatePatientModel patient = IntermediateBuilderUtils.BuildIntermediatePatient(result);
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


        LOGGER.info("@@@@@@@@@@@@@@@@@@@@" + searchEndPoint + "!!!!!!!!!!!!!!!!" + patient);
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

    private Mono<String> callOnInit(Request request) {
        request.getContext().setAction("on_init");
        request.getContext().setProviderId(PROVIDER_ID);
        request.getContext().setProviderUri(PROVIDER_URI);
        try {
            paymentService.saveDataInDb(null, request, ConstantsUtils.ON_INIT);
        } catch (JsonProcessingException | UserException e) {
            LOGGER.error(e.getMessage());
        }

        try {
            LOGGER.info(new ObjectMapper().writeValueAsString(request));
        } catch (JsonProcessingException e) {
            // TODO Auto-generated catch block
            LOGGER.error(e.getMessage());
        }


        return euaWebClient.post()
                .uri(request.getContext().getConsumerUri() + "/on_init")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Init Service call on init:: {} .. Message Id {}", error, getMessageId(request));
                    return Mono.empty(); //TODO:Add appropriate response
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

    private LocalDateTime getLocalDateTimeFromString(String request) {
        return LocalDateTime.parse(request, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

}
