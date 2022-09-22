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

import java.util.Map;
import java.util.Objects;

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

    private static Response generateNack(Exception js) {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        Error err = new Error();
        err.setMessage(js.getMessage());
        err.setType("Search");
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    @Override
    public Mono<Response> processor(String request) {
        Request objRequest;
        Response ack = generateAck();
        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            Request finalObjRequest = objRequest;

            ////TODO: If provider not found donot add patient
            String typeFulfillment = objRequest.getMessage().getOrder().getFulfillment().getType();
            logMessageId(objRequest);
            if(typeFulfillment.equalsIgnoreCase(ConstantsUtils.TELECONSULTATION) || typeFulfillment.equalsIgnoreCase(ConstantsUtils.PHYSICAL_CONSULTATION) || typeFulfillment.equalsIgnoreCase(ConstantsUtils.GROUP_CONSULTATION)) {
                setTeleconsultationInCaseOfGroupConsultation(typeFulfillment, objRequest);
                findPatient(finalObjRequest)
                        .flatMap(result -> createPatient(result, finalObjRequest))
                        .flatMap(result -> createResponse(result, finalObjRequest))
                        .flatMap(this::callOnInit)
                        .flatMap(this::logResponse)
                        .subscribe();
            }
            else{
                return Mono.just(new Response());
            }


        } catch (Exception ex) {
            LOGGER.error("Init Service process::error::onErrorResume:: {}" , ex, ex);
            ack = generateNack(ex);

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
        Request retRequest = ProtocolBuilderUtils.BuildIntitialization(patient, request);

        return Mono.just(retRequest);
    }

    private void putCache()
    {
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

        String abha = request.getMessage().getOrder().getCustomer().getCred();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PATIENT;
        String searchPatient = "?v=full&q=" + abha;
        return webClient.get()
                .uri(searchEndPoint + searchPatient)
                .headers(headers -> headers.setBasicAuth(OPENMRS_USERNAME, OPENMRS_PASSWORD))
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    private void logMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
    }

    private Mono<String> callOnInit(Request request) {
        request.getContext().setAction("on_init");
        try {
			paymentService.saveDataInDb(null,request,ConstantsUtils.ON_INIT);
		} catch (JsonProcessingException | UserException e) {
			  LOGGER.error(e.getMessage());
		}

        WebClient on_webclient = WebClient.create();
        return on_webclient.post()
                .uri(request.getContext().getConsumerUri() + "/on_init")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Init Service call on init:: {}", error, error);
                    return Mono.empty(); //TODO:Add appropriate response
                });
    }

    private void setTeleconsultationInCaseOfGroupConsultation(String typeFulfillment, Request objRequest) {
        if(typeFulfillment.equalsIgnoreCase(ConstantsUtils.GROUP_CONSULTATION)) {
            objRequest.getMessage().getIntent().getFulfillment().setType(ConstantsUtils.TELECONSULTATION);
        }
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
    public Mono<String> logResponse(java.lang.String result) {

        LOGGER.info("OnInit::Log::Response:: {}" , result);

        return Mono.just(result);
    }

}
