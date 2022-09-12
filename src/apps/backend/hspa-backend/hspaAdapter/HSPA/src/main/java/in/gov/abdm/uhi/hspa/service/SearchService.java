package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
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
import java.util.stream.Collectors;

@Service
public class SearchService implements IService {

    private static final String API_RESOURCE_PROVIDER = "provider";
    private static final Logger LOGGER = LogManager.getLogger(SearchService.class);
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    @Value("${spring.openmrs_api}")
    String OPENMRS_API;
    @Value("${spring.gateway_uri}")
    String GATEWAY_URI;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Autowired
    WebClient webClient;

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
    public Mono<Response> processor(@RequestBody String request) {

        //Verify message
        Request objRequest = new Request();
        Response ack = generateAck();
        try {
            LOGGER.info("Processing::Search::Request::" + request);
            objRequest = new ObjectMapper().readValue(request, Request.class);
            String typeFulfillment = objRequest.getMessage().getIntent().getFulfillment().getType();
            if(typeFulfillment.equalsIgnoreCase("Teleconsultation") || typeFulfillment.equalsIgnoreCase("PhysicalConsultation")) {
                Request finalObjRequest = objRequest;
                run(objRequest, request)
                        .flatMap(this::transformObject)
                        .flatMap(collection -> generateCatalog(collection, finalObjRequest))
                        .flatMap(catalog -> callOnSerach(catalog, finalObjRequest.getContext()))
                        .flatMap(this::logResponse)
                        .subscribe();
            }
            else {
                return Mono.just(new Response());
            }
        } catch (Exception ex) {
            LOGGER.error("Search Proccessor::error::onErrorResume::" + ex);
            ack = generateNack(ex);
        }

        return Mono.just(ack);
    }

    private Mono<List<IntermediateProviderModel>> transformObject(String result) {

        LOGGER.info("Processing::Search::TransformObject" + result);
        List<IntermediateProviderModel> collection = new ArrayList<>();
        try {

            collection = IntermediateBuilderUtils.BuildIntermediateObj(result);

        } catch (Exception ex) {
            LOGGER.error("Search Service Transform Object::error::" + ex);
        }
        return Mono.just(collection);

    }

    private Mono<Catalog> generateCatalog(List<IntermediateProviderModel> collection, Request request) {

        LOGGER.info("Processing::Search::CatalogGeneration" + collection);
        Catalog catalog = new Catalog();

        try {
            List<IntermediateProviderModel> filterdList = filterListByAttributes(collection, request);
            catalog = ProtocolBuilderUtils.BuildCatalog(filterdList, request);

        } catch (Exception ex) {

            LOGGER.error("Search Service Generate Catalog::error::" + ex);
        }
        return Mono.just(catalog);

    }

    private List<IntermediateProviderModel> filterListByAttributes(List<IntermediateProviderModel> collection, Request request) {

        LOGGER.info("Processing::Search::FilterListByAttribute" + collection);

        Map<String, String> filters = IntermediateBuilderUtils.BuildSearchParametersIntent(request);
        List<IntermediateProviderModel> filteredList = collection;
        try {
            if (filters.get("languages") != null) {
                filteredList = filteredList.stream().filter(imd -> imd.getLanguages().toLowerCase().contains(filters.get("languages"))).collect(Collectors.toList());
            }
            if (filters.get("speciality") != null) {
                filteredList = filteredList.stream().filter(imd -> imd.getSpeciality().equalsIgnoreCase(filters.get("speciality"))).collect(Collectors.toList());
            }
            if (filters.get("type") != null && filters.get("type").equalsIgnoreCase("PhysicalConsultation")) {
                filteredList = filteredList.stream().filter(imd -> imd.getIs_physical_consultation().equals("true")).collect(Collectors.toList());
            }
            if (filters.get("type") != null && filters.get("type").equalsIgnoreCase("TeleConsultation")) {
                filteredList = filteredList.stream().filter(imd -> imd.getIs_teleconsultation().equals("true")).collect(Collectors.toList());
            }
        } catch (Exception ex) {
            LOGGER.error("Search Service Filter by Attribute::error::" + ex);
        }
        return filteredList;

    }

    private Mono<String> callOnSerach(Catalog catalog, Context context) {

        Request onSearchRequest = new Request();
        Message objMessage = new Message();
        objMessage.setCatalog(catalog);
        onSearchRequest.setMessage(objMessage);
        context.setProviderId(PROVIDER_URI);
        if(context.getConsumerId().equalsIgnoreCase("eua-nha"))
            context.setProviderUri(PROVIDER_URI);
        else
            context.setProviderUri("http://121.242.73.124:8084/api/v1");
        context.setAction("on_search");
        onSearchRequest.setContext(context);
        onSearchRequest.getContext().setAction("on_search");

        LOGGER.info("Processing::Search::CallOnSearch" + onSearchRequest);
        WebClient on_webclient = WebClient.create();

        return on_webclient.post()
                .uri(GATEWAY_URI + "/on_search")
                .body(BodyInserters.fromValue(onSearchRequest))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Unable to call gateway :error::onErrorResume::" + error);
                    return Mono.empty();
                });
    }

    @Override
    public Mono<String> run(Request request, String s) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PROVIDER;

        Map<String, String> searchParams = IntermediateBuilderUtils.BuildSearchParametersIntent(request);
        String searchString = buildSearchString(searchParams);

        return webClient.get()
                .uri(searchEndPoint + searchString)
                .exchangeToMono(clientResponse -> clientResponse.bodyToMono(String.class))
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("External API::error::onErrorResume::" + error);
                    return Mono.empty();
                });

    }

    private String buildSearchString(Map<String, String> params) {
        String searchString = "?v=full&q=";//custom:uuid,display,identifier,person:(uuid,display,gender,age),attributes:(uuid,display,value,attributeType:(uuid,display)));
        String value = "";
        if (params.get("hprid") == null || Objects.equals(params.get("hprid"), "")) {
            value = params.getOrDefault("name", "");
        } else {
            value = params.getOrDefault("hprid", "");
        }
        return searchString + value;
    }

    @Override
    public Mono<String> logResponse(String result) {

        LOGGER.info("OnSearch::Log::Response::" + result);
        return Mono.just(result);
    }
}
