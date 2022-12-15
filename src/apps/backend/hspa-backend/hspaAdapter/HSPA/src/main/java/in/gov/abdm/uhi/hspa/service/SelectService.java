package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.IntermediateAppointmentModel;
import in.gov.abdm.uhi.hspa.models.IntermediateAppointmentSearchModel;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderAppointmentModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import in.gov.abdm.uhi.hspa.utils.IntermediateBuilderUtils;
import in.gov.abdm.uhi.hspa.utils.ProtocolBuilderUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.util.function.Tuple2;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

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

    public SelectService(WebClient webClient, SearchService searchService) {
        this.webClient = webClient;
        this.searchService = searchService;
    }

    public static Response generateAck() {

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

    public Mono<Response> processor(@RequestBody String request) throws UserException {

        Request objRequest = null;
        Response ack = generateAck();

        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            String messageId = CommonService.getMessageId(objRequest);
            LOGGER.info("Processing::Search(Select)::Request:: {}. Message id is {}", request, messageId);

            logMessageId(objRequest);
            if (CommonService.isTestHspaProviderSearchOrDoctorSearch(objRequest, true)) {
                Request finalObjRequest = objRequest;
                run(objRequest, request).zipWith(getAllAppointmentTypes(objRequest))
                        .flatMap(pair -> getProviderAppointment(pair, finalObjRequest))
                        .flatMap(res -> getProviderAppointments(res, finalObjRequest))
                        .flatMap(resp -> transformObject(resp, finalObjRequest))
                        .flatMap(mapResult -> generateCatalog(mapResult, finalObjRequest))
                        .flatMap(catalog -> callOnSerach(catalog, finalObjRequest.getContext()))
                        .flatMap(log -> logResponse(log, finalObjRequest))
                        .subscribe();
            } else {
                return Mono.just(new Response());
            }
        } catch (Exception ex) {
            LOGGER.error("Search(Select) service processor::error::onErrorResume:: {}", ex, ex);
            ack = CommonService.setMessageidAndTxnIdInNack(objRequest, ex);
        }

        return Mono.just(ack);
    }

    @Override
    public Mono<String> run(Request request, String s) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PROVIDER;

        Map<String, String> searchParams = IntermediateBuilderUtils.BuildSearchParametersIntent(request, true);

        String searchString = buildSearchString(searchParams);

        LOGGER.info("$$$$$$$$$$$$$$$$$$$$$$$$$$" + searchParams + "!!!!!!!!!!!!!!" + searchEndPoint + "@@@@@@@@@@@@@@@@" + searchString);


        return webClient.get()
                .uri(searchEndPoint + searchString)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class));
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
            LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
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
            return Mono.empty();
        }
    }

    private void logMessageId(Request objRequest) {
        String messageId = CommonService.getMessageId(objRequest);
        LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
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
            catalog = ProtocolBuilderUtils.BuildProviderCatalog(collection, request.getMessage().getIntent().getProvider().getFulfillments().get(0).getType());

        } catch (Exception ex) {

            LOGGER.error("Select service generate catalog::error::onErrorResume:: {} \n Message Id is {}", ex, messageId);
        }
        return Mono.just(catalog);

    }

    private Mono<String> callOnSerach(Catalog catalog, Context context) {
        Request onSearchRequest = new Request();
        Message objMessage = new Message();
        objMessage.setCatalog(catalog);
        context.setProviderId(PROVIDER_ID);
        context.setProviderUri(PROVIDER_URI);

        context.setAction("on_search");
        onSearchRequest.setMessage(objMessage);
        onSearchRequest.setContext(context);
        onSearchRequest.getContext().setAction("on_search");
        try {
            LOGGER.info("Processing::Search::CallOnSelect {} .. Message Id is {}", new ObjectMapper().writeValueAsString(onSearchRequest), context.getMessageId());
        } catch (JsonProcessingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return euaWebClient.post()
                .uri(context.getConsumerUri() + "/on_search")
                .body(BodyInserters.fromValue(onSearchRequest))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Select Service Call on_search::error::onErrorResume:: {} \n Message Id is {}", error, context.getMessageId());
                    return Mono.empty();
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
}
