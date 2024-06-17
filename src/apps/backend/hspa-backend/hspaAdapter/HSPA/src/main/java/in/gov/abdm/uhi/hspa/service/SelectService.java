package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.IntermediateAppointmentModel;
import in.gov.abdm.uhi.hspa.models.IntermediateAppointmentSearchModel;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderAppointmentModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
import java.util.*;

@Service
public class SelectService implements IService {

    private static final String API_RESOURCE_PROVIDER = "provider";
    private static final String API_RESOURCE_APPOINTMENTSCHEDULING_TIMESLOT = "appointmentscheduling/timeslot?limit=100";
    private static final String API_RESOURCE_APPOINTMENT_TYPE = "appointmentscheduling/appointmenttype?q=";
    private static final Logger LOGGER = LogManager.getLogger(SelectService.class);
    final
    WebClient webClient;
    final
    SearchService searchService;
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
    ObjectMapper objectMapper;

    final
    HspaUtility hspaUtility;

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

    public SelectService(WebClient webClient, SearchService searchService, HspaUtility hspaUtility) {
        this.webClient = webClient;
        this.searchService = searchService;
        this.hspaUtility = hspaUtility;
    }

    public static Response generateAck() {

        MessageAck msz = MessageAck.builder().build();
        Response res = Response.builder().build();
        Ack ack = Ack.builder().build();
        ack.setStatus("ACK");
        msz.setAck(ack);
        Error err = new Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {

        Request objRequest = null;
        objRequest = objectMapper.readValue(request, Request.class);
        String messageId = CommonService.getMessageId(objRequest);
        LOGGER.info("Processing::Search(Select)::Request:: {}. Message id is {}", request, messageId);

        if(Boolean.parseBoolean(isHeaderEnabled)) {
            return processSelectWithHeaderVerification(request, headers, objRequest);
        }
        else {
            return processSelectCall(request, objRequest);
        }


    }

    private Mono<Response> processSelectWithHeaderVerification(String request, Map<String, String> headers, Request objRequest) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        HspaUtility.checkAuthHeader(headers, objRequest);
        Map<String, String> keyIdMap = hspaUtility.getKeyIdMapFromHeaders(headers, objRequest);
        Mono<List<Subscriber>> subscriberDetails = hspaUtility.getSubscriberDetailsOfEua(objRequest, keyIdMap.get("subscriber_id"),keyIdMap.get("pub_key_id"));
        return subscriberDetails.flatMap(lookupRes -> {
            if (!lookupRes.isEmpty()) {
                try {
                    if (hspaUtility.verifyHeaders(objRequest, headers, GlobalConstants.AUTHORIZATION.toLowerCase(), lookupRes.get(0).getEncr_public_key(), request)) {
                        return processSelectCall(request, objRequest);
                    } else {
                        LOGGER.error("{} | SelectService::processor::Header verification failed", objRequest.getContext().getMessageId());
                        return Mono.error(new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage()));
                    }
                } catch (JsonProcessingException | NoSuchAlgorithmException | NoSuchProviderException |
                         InvalidKeyException | SignatureException | InvalidKeySpecException | UserException e) {
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

    private Mono<Response> processSelectCall(String request, Request finalObjRequest1) throws UserException {
        if (CommonService.isTestHspaProviderSearchOrDoctorSearch(finalObjRequest1, true)) {
            run(finalObjRequest1, request).zipWith(getAllAppointmentTypes(finalObjRequest1))
                    .flatMap(pair -> getProviderAppointment(pair, finalObjRequest1))
                    .flatMap(res -> getProviderAppointments(res, finalObjRequest1))
                    .flatMap(resp -> transformObject(resp, finalObjRequest1))
                    .flatMap(mapResult -> generateCatalog(mapResult, finalObjRequest1))
                    .flatMap(catalog -> {
                        try {
                            return callOnSerach(catalog, finalObjRequest1.getContext());
                        } catch (JsonProcessingException | NoSuchAlgorithmException e) {
                            return Mono.error(new HspaException(e.getMessage()));
                        } catch (NoSuchProviderException | InvalidKeySpecException e) {
                            return Mono.error(new InvalidKeyException(e.getMessage()));
                        }
                    })
                    .flatMap(log -> logResponse(log, finalObjRequest1))
                    .subscribe();
        } else {
            return Mono.just(generateAck());
        }
        return Mono.just(CommonService.generateAck());
    }

    @Override
    public Mono<String> run(Request request, String s) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PROVIDER;

        Map<String, String> searchParams = IntermediateBuilderUtils.BuildSearchParametersIntent(request, true);

        String searchString = buildSearchString(searchParams);

        LOGGER.info("SearchParams {}. Search endpoint {}. Search string {}", searchParams,searchEndPoint , searchString);

        return webClient.get()
                .uri(searchEndPoint + searchString)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception {
        return null;
    }

    public Mono<String> getAllAppointmentTypes(Request request) {

        String appointmentType = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getType();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT_TYPE + appointmentType;

        return webClient.get()
                .uri(searchEndPoint)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    private Mono<IntermediateAppointmentSearchModel> getProviderAppointment(Tuple2 result, Request request) {

        String messageId = CommonService.getMessageId(request);
        LOGGER.info("Processing::Search(Select)::getProviderAppointment:: {}... and Message Id is {}", result, messageId);

        IntermediateAppointmentSearchModel appointmentSearchModel = new IntermediateAppointmentSearchModel();
        appointmentSearchModel.providers = new ArrayList<>();
        appointmentSearchModel.appointmentTypes = new ArrayList<>();


        try {
            Map<String, String> searchParams = IntermediateBuilderUtils.BuildSearchParametersIntent(request, true);
            appointmentSearchModel.providers = IntermediateBuilderUtils.BuildIntermediateProviderDetails(result.getT1().toString());
            appointmentSearchModel.appointmentTypes = IntermediateBuilderUtils.BuildIntermediateAppointment(result.getT2().toString());
            appointmentSearchModel.startDate = searchParams.get("fromDate");
            appointmentSearchModel.endDate = searchParams.get("toDate");
            appointmentSearchModel.view = "full";

        } catch (Exception ex) {
            LOGGER.error("Search(Select) service Get Provider Id::error::onErrorResume:: {}... Message Id is {}", ex, messageId);
            return Mono.error(new HspaException(ex.getMessage()));
        }
        return Mono.just(appointmentSearchModel);
    }

    Mono<String> getProviderAppointments(IntermediateAppointmentSearchModel data, Request request) {
        if (!data.providers.isEmpty()) {
            String appointmentType = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getType();
            String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENTSCHEDULING_TIMESLOT;

            List<IntermediateAppointmentModel> appointmentTypeList = data.getAppointmentTypes().stream().filter(res -> res.getAppointmentTypeDisplay().equalsIgnoreCase(appointmentType)).toList();

            String provider = data.getProviders().get(0).getId();
            String appointment = appointmentTypeList.get(0).getAppointmentTypeUUID();
            String startDate = data.getStartDate();
            String endDate = data.getEndDate();

            String filterProvider = "&provider=" + provider;
            String filterAppointmentType = "&appointmentType=" + appointment;
            String filterStartDate = "&fromDate=" + startDate;
            String filterEndDate = "&toDate=" + endDate;
            String view = "&v=" + data.getView();

            final String uri = searchEndPoint + filterProvider + filterAppointmentType + filterStartDate + filterEndDate + view;

            return webClient.get()
                    .uri(uri)
                    .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
        } else {
            LOGGER.error("SelectService :: getProviderAppointments:: error.... No providers found");
            return Mono.empty();
        }
    }

    private Mono<List<IntermediateProviderAppointmentModel>> transformObject(String result, Request request) {
        String messageId = CommonService.getMessageId(request);

        LOGGER.info("Processing::Search(Select)::transformObject:: {}... Message Id is {}", result, messageId);
        List<IntermediateProviderAppointmentModel> collection = new ArrayList<>();
        try {

            collection = IntermediateBuilderUtils.BuildIntermediateProviderAppoitmentObj(result);

        } catch (Exception ex) {
            LOGGER.error("Select service Transform Object::error::onErrorResume:: {}... Message Id is {}", ex, messageId);
        }
        return Mono.just(collection);
    }

    private Mono<Catalog> generateCatalog(List<IntermediateProviderAppointmentModel> collection, Request request) {
        String messageId = CommonService.getMessageId(request);

        Catalog catalog = new Catalog();
        try {
            String typeFulfillment = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getType();
            catalog = ProtocolBuilderUtils.BuildProviderCatalog(collection, typeFulfillment, request);

        } catch (Exception ex) {

            LOGGER.error("Select service generate catalog::error::onErrorResume:: {} \n Message Id is {}", ex, messageId);
        }
        return Mono.just(catalog);

    }

    private Mono<String> callOnSerach(Catalog catalog, Context context) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        Request onSearchRequest = new Request();
        Message objMessage = new Message();
        objMessage.setCatalog(catalog);
        context.setProviderId(PROVIDER_ID);
        context.setProviderUri(PROVIDER_URI);

        context.setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);
        onSearchRequest.setMessage(objMessage);
        onSearchRequest.setContext(context);
        onSearchRequest.getContext().setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);
        String onSelectRequestString = objectMapper.writeValueAsString(onSearchRequest);
        LOGGER.info("Processing::Search::CallOnSelect {} .. Message Id is {}", onSelectRequestString, context.getMessageId());

        return euaWebClient.post()
                .uri(context.getConsumerUri() + "/on_search")
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onSelectRequestString, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onSelectRequestString))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    LOGGER.error("Select Service Call on_search::error::onErrorResume:: {} \n Message Id is {}", error, context.getMessageId());
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

        String messageId = CommonService.getMessageId(request);
        LOGGER.info("OnSearch(Select)::Log::Response:: {} \n Message Id is {}", result, messageId);

        return Mono.just(result);
    }

    @Override
    public boolean updateOrderStatus(String status, String orderId) {
        return false;
    }
}
