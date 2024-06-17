package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.IntermediateAppointmentModel;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class SearchService implements IService {

    private static final String API_RESOURCE_PROVIDER = "provider";
    private static final String API_RESOURCE_APPOINTMENTSCHEDULING_TIMESLOT = "appointmentscheduling/timeslot?limit=100";

    private static final Logger LOGGER = LogManager.getLogger(SearchService.class);
    private static final String API_RESOURCE_APPOINTMENT_TYPE = "appointmentscheduling/appointmenttype?q=";
    final
    WebClient webClient;
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    @Value("${spring.openmrs_api}")
    String OPENMRS_API;
    @Value("${spring.gateway_uri}")
    String GATEWAY_URI;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.provider_id}")
    String PROVIDER_ID;
    @Autowired
    WebClient euaWebClient;

    @Value("${spring.gateway.publicKey}")
    String GATEWAY_PUBLIC_KEY;

    @Value("${spring.hspa.subsId}")
    String HSPA_SUBS_ID;

    @Value("${spring.hspa.privKey}")
    String HSPA_PRIV_KEY;

    @Value("${spring.hspa.pubKeyId}")
    String HSPA_PUBKEY_ID;

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    final
    ObjectMapper objectMapper;

    final
    HspaUtility hspaUtility;

    final
    Crypt crypt;



    public SearchService(WebClient webClient, Crypt crypt, ObjectMapper objectMapper, HspaUtility hspaUtility) {
        this.webClient = webClient;
        this.crypt = crypt;
        this.objectMapper = objectMapper;
        this.hspaUtility = hspaUtility;
    }

    public static String getParsedDate(String date) throws ParseException {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(ConstantsUtils.DATE_TIME_PATTERN);
        Date dateParsed = null;
        dateParsed = simpleDateFormat.parse(date);

        return simpleDateFormat.format(dateParsed);
    }

    @Override
    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {

        //Verify message
        Request objRequest = null;
        objRequest = objectMapper.readValue(request, Request.class);
        if(Boolean.parseBoolean(isHeaderEnabled)) {
            return processSearchWithHeaderVerification(request, headers, objRequest);
        }
        else{
            return processSearch(request, objRequest, objRequest);
        }
    }

    private Mono<Response> processSearchWithHeaderVerification(String request, Map<String, String> headers, Request objRequest) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException, SignatureException, InvalidKeyException, UserException {
        hspaUtility.checkXGatewayHeader(headers, objRequest);

        boolean isHeaderVerified = hspaUtility.getHeaderVerificationResult(request, headers, objRequest, GlobalConstants.X_GATEWAY_AUTHORIZATION.toLowerCase(), GATEWAY_PUBLIC_KEY);
        if (isHeaderVerified) {
            LOGGER.info("Processing::Search::Request:: {}.. Message Id is {}", request, CommonService.getMessageId(objRequest));
            if (CommonService.isTestHspaProviderSearchOrDoctorSearch(objRequest, false)) {
                return processSearch(request, objRequest, objRequest);
            } else {
                LOGGER.error(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, CommonService.getMessageId(objRequest));
                throw new HspaException("Invalid search Schema");
            }
        }
        else {
            LOGGER.error("{} | SearchService::processor::Header verification failed", objRequest.getContext().getMessageId());
            return Mono.error(new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage()));
        }
    }

    private Mono<Response> processSearch(String request, Request objRequest, Request finalObjRequest) {
        return run(objRequest, request)
                .flatMap(res -> transformObject(res, finalObjRequest))
                .flatMap(providers -> filterDoctorsBasedOnSearchIntent(providers, finalObjRequest))
                .flatMap(resp -> filterDoctorsBasedOnAvailability(resp, finalObjRequest))
                .flatMap(collection -> generateCatalog(collection, finalObjRequest))
                .flatMap(catalog -> {
                    try {
                        callOnSerach(catalog, finalObjRequest.getContext()).subscribe();
                    } catch (JsonProcessingException | NoSuchAlgorithmException | NoSuchProviderException |
                             InvalidKeySpecException e) {
                        LOGGER.error("{} | {}::processor::error::{}", finalObjRequest.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                        return Mono.error(new InvalidKeyException(GatewayError.INVALID_KEY.getMessage()));
                    } catch (Exception e) {
                        LOGGER.error("{} | {}::processor::error::{}", finalObjRequest.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                        return Mono.error(new HspaException(GatewayError.INTERNAL_SERVER_ERROR.getMessage()));
                    }
                    return Mono.just(CommonService.generateAck());
                });
    }


    private Mono<List<IntermediateProviderModel>> filterDoctorsBasedOnAvailability(List<IntermediateProviderModel> resp, Request finalObjRequest) {

        Mono<String> stringJsonAppointmentTyoes = getAllAppointmentTypes(finalObjRequest);
        return stringJsonAppointmentTyoes.flatMap(result -> parseStringJsonAppointmentTypes(result, finalObjRequest))
                .flatMap(result ->
                        filterProviderIfSlotsPresent(resp, finalObjRequest, result).collectList());
    }

    private Flux<IntermediateProviderModel> filterProviderIfSlotsPresent(List<IntermediateProviderModel> resp, Request finalObjRequest, IntermediateAppointmentModel appointmentType) {

        return Flux.fromIterable(resp).flatMap(provider -> {
            try {
                return getProviderSlots(finalObjRequest, appointmentType, provider).flatMap(isSlotPresent -> {
                    if (Boolean.TRUE.equals(isSlotPresent)) {
                        return Mono.just(provider);
                    }
                    return Mono.empty();
                });
            } catch (ParseException e) {
                return Mono.error(new HspaException(e.getMessage()));
            }
        });
    }

    private Mono<Boolean> getProviderSlots(Request finalObjRequest, IntermediateAppointmentModel appointmentType, IntermediateProviderModel provider) throws ParseException {

        String startDate = finalObjRequest.getMessage().getIntent().getFulfillment().getStart().getTime().getTimestamp();
        String endDate = finalObjRequest.getMessage().getIntent().getFulfillment().getEnd().getTime().getTimestamp();
        Mono<String> result = callProviderSlotsApi(getParsedDate(startDate), endDate, provider.getUuid(), appointmentType.getAppointmentTypeUUID());
        return result.flatMap(timeslots -> Mono.just(!timeslots.equalsIgnoreCase("{\"results\":[]}")));

    }

    Mono<String> callProviderSlotsApi(String startDate, String endDate, String providerUuid, String appointmentTypeUuid) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENTSCHEDULING_TIMESLOT;

        String filterProvider = "&provider=" + providerUuid;
        String filterAppointmentType = "&appointmentType=" + appointmentTypeUuid;
        String filterStartDate = "&fromDate=" + startDate;
        String filterEndDate = "&toDate=" + endDate;
        String view = "&v=" + "custom:uuid";
        String includeFull = "&includeFull=" + "false";

        final String uri = searchEndPoint + filterProvider + filterAppointmentType + filterStartDate + filterEndDate + view + includeFull;

        return webClient.get()
                .uri(uri)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }


    private Mono<IntermediateAppointmentModel> parseStringJsonAppointmentTypes(String json, Request finalObjRequest) {
        IntermediateAppointmentModel intermediateAppointmentModel = IntermediateBuilderUtils.BuildAppointmenttype(json, finalObjRequest.getMessage().getIntent().getFulfillment().getType());
        return Mono.just(intermediateAppointmentModel);
    }

    public Mono<String> getAllAppointmentTypes(Request request) {

        String appointmentType = request.getMessage().getIntent().getFulfillment().getType();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT_TYPE + appointmentType;

        return webClient.get()
                .uri(searchEndPoint)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
    }

    private Mono<List<IntermediateProviderModel>> transformObject(String result, Request request) {

        LOGGER.info("Processing::Search::.. Message Id is {}", CommonService.getMessageId(request));

        List<IntermediateProviderModel> collection = new ArrayList<>();
        try {

            collection = IntermediateBuilderUtils.BuildIntermediateObj(result);

        } catch (Exception ex) {
            LOGGER.error("Search Service Transform Object::error:: {}... Message Id is {}", ex, CommonService.getMessageId(request));
        }
        return Mono.just(collection);
    }


    private Mono<Catalog> generateCatalog(List<IntermediateProviderModel> collection, Request request) {

        LOGGER.info("Processing::Search::CatalogGeneration {}.. Message Id is {}", collection, CommonService.getMessageId(request));
        Catalog catalog = new Catalog();

        try {
            catalog = ProtocolBuilderUtils.BuildCatalog(collection, request, false);

        } catch (Exception ex) {

            LOGGER.error("Search Service Generate Catalog::error:: {} ... Message Id is {}", ex, CommonService.getMessageId(request));
        }
        return Mono.just(catalog);
    }

    private Mono<List<IntermediateProviderModel>> filterDoctorsBasedOnSearchIntent(List<IntermediateProviderModel> collection, Request request) {

        LOGGER.info("Processing::Search::FilterListByAttribute {} .. Message Id is {}", collection, CommonService.getMessageId(request));

        Map<String, String> filters = IntermediateBuilderUtils.BuildSearchParametersIntent(request, false);

        List<IntermediateProviderModel> filteredList = collection;

        try {
            if (null != filters.get("languages")) {
                filteredList = filteredList.stream().filter(imd -> imd.getLanguages().toLowerCase().contains(filters.get("languages"))).toList();
            }
            if (null != filters.get("speciality")) {
                filteredList = filteredList.stream().filter(imd -> imd.getSpeciality().equalsIgnoreCase(filters.get("speciality"))).toList();
            }
            if (null != filters.get("type") && filters.get("type").equalsIgnoreCase(ConstantsUtils.PHYSICAL_CONSULTATION) || filters.get("type").equalsIgnoreCase(ConstantsUtils.PHYSICAL_OPD)) {
                filteredList = filteredList.stream().filter(imd -> imd.getIs_physical_consultation().equals("true")).toList();
            }
            if (null != filters.get("type") && filters.get("type").equalsIgnoreCase(ConstantsUtils.TELECONSULTATION)) {
                filteredList = filteredList.stream().filter(imd -> imd.getIs_teleconsultation().equals("true")).toList();
            }
            if (null != filters.get("fromDate") && null != filters.get("toDate")) {

                filteredList = filteredList.stream().filter(imd -> imd.getIs_teleconsultation().equals("true")).toList();
            }

        } catch (Exception ex) {
            LOGGER.error("Search Service Filter by Attribute::error:: {} .. Message Id is {}", ex, CommonService.getMessageId(request));
        }
        return Mono.just(filteredList);

    }

    private Mono<String> callOnSerach(Catalog catalog, Context context) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {

        Request onSearchRequest = new Request();
        Message objMessage = new Message();

        objMessage.setCatalog(catalog);
        onSearchRequest.setMessage(objMessage);
        context.setProviderId(PROVIDER_ID);
        context.setProviderUri(PROVIDER_URI);

        context.setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);
        onSearchRequest.setContext(context);
        onSearchRequest.getContext().setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);

        String onSearchRequestString = objectMapper.writeValueAsString(onSearchRequest);
        LOGGER.info("Processing::Search::CallOnSearch {} .. Message Id is {}", onSearchRequestString, context.getMessageId());

        return euaWebClient.post()
                .uri(GATEWAY_URI + "/" + ConstantsUtils.ON_SEARCH_ENDPOINT)
                .contentType(MediaType.APPLICATION_JSON)
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onSearchRequestString, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onSearchRequestString))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    LOGGER.error("Unable to call gateway :error::onErrorResume:: {} .. Message Id is {}", error, context.getMessageId());
                    return Mono.error(new HspaException(error.getMessage()));
                });
    }

    @Override
    public Mono<String> run(Request request, String s) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PROVIDER;

        Map<String, String> searchParams = IntermediateBuilderUtils.BuildSearchParametersIntent(request, false);
        String searchString = buildSearchString(searchParams);

        return webClient.get()
                .uri(searchEndPoint + searchString)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class))
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("External API::error::onErrorResume:: {}, Message Id is {}", error, CommonService.getMessageId(request));
                    return Mono.error(new HspaException(error.getMessage()));
                });

    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception {
        return null;
    }

    private String buildSearchString(Map<String, String> params) {
        String searchString = "?v=full&q=";
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

        LOGGER.info("OnSearch::Log::Response:: {} \n Message Id is {}", result, CommonService.getMessageId(request));
        return Mono.just(result);
    }

    @Override
    public boolean updateOrderStatus(String status, String orderId) {
        return false;
    }
}
