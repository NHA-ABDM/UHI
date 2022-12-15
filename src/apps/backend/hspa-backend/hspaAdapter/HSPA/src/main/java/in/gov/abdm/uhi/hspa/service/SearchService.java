package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderModel;
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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
public class SearchService implements IService {

    private static final String API_RESOURCE_PROVIDER = "provider";
    private static final Logger LOGGER = LogManager.getLogger(SearchService.class);
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

    public SearchService(WebClient webClient) {
        this.webClient = webClient;
    }

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
    public Mono<Response> processor(@RequestBody String request) throws UserException {

        //Verify message
        Request objRequest = null;
        Response ack = generateAck();
        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            LOGGER.info("Processing::Search::Request:: {}.. Message Id is {}", request, CommonService.getMessageId(objRequest));

            if (CommonService.isTestHspaProviderSearchOrDoctorSearch(objRequest, false)) {
                Request finalObjRequest = objRequest;
                run(objRequest, request)
                        .flatMap(res -> transformObject(res, finalObjRequest))
                        .flatMap(collection -> generateCatalog(collection, finalObjRequest, false))
                        .flatMap(catalog -> callOnSerach(catalog, finalObjRequest.getContext()))
                        .flatMap(log -> logResponse(log, finalObjRequest))
                        .subscribe();
            } else {
                LOGGER.error(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, CommonService.getMessageId(objRequest));
                throw new UserException("Invalid search Schema");
            }

        } catch (Exception ex) {
            LOGGER.error("Search Proccessor::error::onErrorResume:: {}, Message Id is {}", ex, CommonService.getMessageId(objRequest));
            ack = CommonService.setMessageidAndTxnIdInNack(objRequest, ex);
        }
        return Mono.just(ack);
    }


    private Mono<List<IntermediateProviderModel>> transformObject(String result, Request request) {

        LOGGER.info("Processing::Search::TransformObject {}.. Message Id is {}", result, CommonService.getMessageId(request));

        List<IntermediateProviderModel> collection = new ArrayList<>();
        try {

            collection = IntermediateBuilderUtils.BuildIntermediateObj(result);

        } catch (Exception ex) {
            LOGGER.error("Search Service Transform Object::error:: {}... Message Id is {}", ex, CommonService.getMessageId(request));
        }
        return Mono.just(collection);
    }


    private Mono<Catalog> generateCatalog(List<IntermediateProviderModel> collection, Request request, boolean isSecondSearch) {

        LOGGER.info("Processing::Search::CatalogGeneration {}.. Message Id is {}", collection, CommonService.getMessageId(request));
        Catalog catalog = new Catalog();

        try {
            List<IntermediateProviderModel> filterdList = filterListByAttributes(collection, request);
            catalog = ProtocolBuilderUtils.BuildCatalog(filterdList, request, isSecondSearch);

        } catch (Exception ex) {

            LOGGER.error("Search Service Generate Catalog::error:: {} ... Message Id is {}", ex, CommonService.getMessageId(request));
        }
        return Mono.just(catalog);

    }

    private List<IntermediateProviderModel> filterListByAttributes(List<IntermediateProviderModel> collection, Request request) {

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

        } catch (Exception ex) {
            LOGGER.error("Search Service Filter by Attribute::error:: {} .. Message Id is {}", ex, CommonService.getMessageId(request));
        }
        return filteredList;

    }

    private Mono<String> callOnSerach(Catalog catalog, Context context) {

        Request onSearchRequest = new Request();
        Message objMessage = new Message();

        objMessage.setCatalog(catalog);
        onSearchRequest.setMessage(objMessage);
        context.setProviderId(PROVIDER_ID);
        context.setProviderUri(PROVIDER_URI);

        context.setAction("on_search");
        onSearchRequest.setContext(context);
        onSearchRequest.getContext().setAction("on_search");

        LOGGER.info("---------------------------------------------");
        try {
            LOGGER.info(new ObjectMapper().writeValueAsString(onSearchRequest));
        } catch (Exception e) {
            LOGGER.error(e.getMessage());
        }

        try {
            LOGGER.info("Processing::Search::CallOnSearch {} .. Message Id is {}", new ObjectMapper().writeValueAsString(onSearchRequest), context.getMessageId());
        } catch (JsonProcessingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }


        return euaWebClient.post()
                .uri(GATEWAY_URI + "/on_search")
                .body(BodyInserters.fromValue(onSearchRequest))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Unable to call gateway :error::onErrorResume:: {} .. Message Id is {}", error, context.getMessageId());
                    return Mono.empty();
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
                    return Mono.empty();
                });

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
}
