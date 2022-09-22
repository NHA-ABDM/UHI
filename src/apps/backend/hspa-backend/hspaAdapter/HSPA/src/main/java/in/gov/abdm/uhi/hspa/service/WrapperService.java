package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderModel;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class WrapperService {
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    private static final String OPENMRS_API = "/ws/rest/v1/";
    private static final String API_RESOURCE_PROVIDER = "provider";

    WebClient webClient = WebClient.create();

    @Autowired
    ObjectMapper mapper;
    private static final Logger LOGGER = LogManager.getLogger(WrapperService.class);

    public Mono<Response> processorSearch(@RequestBody Request request) {

        //Verify message
        Response ack = generateAck(mapper);

        Mono<Response> responseMono = Mono.just(ack);
        run(request)
                .flatMap(this::transformObject)
                .flatMap(collection-> generateCatalog(collection, request))
                .flatMap(catalog -> callOnSerach(catalog, request.getContext()))
                .subscribe();

        return responseMono;
    }

    private Mono<List<IntermediateProviderModel>> transformObject(String result) {

        List<IntermediateProviderModel> collection = new ArrayList<IntermediateProviderModel>();
        try {

            collection = IntermediateBuilderUtils.BuildIntermediateObj(result);

        } catch (Exception ex) {
            LOGGER.error(ex.getMessage());
        }
        return Mono.just(collection);

    }

    private Mono<Catalog> generateCatalog(List<IntermediateProviderModel> collection, Request request) {

        Catalog catalog = new Catalog();
        List<IntermediateProviderModel> filteredList = collection;
        try {
            Map<String, String> filters = getSearchParams(request);
            if(filters.get("hprid") != null)
            {
                filteredList= collection.stream().filter(imd -> imd.getHpr_id().contains(filters.get("hprid"))).collect(Collectors.toList());

            }
            catalog = ProtocolBuilderUtils.BuildCatalog(filteredList);

        } catch (Exception ex) {
            LOGGER.error(ex.getMessage());
        }
        return Mono.just(catalog);

    }

    private Mono<String> callOnSerach (Catalog catalog, Context context)
    {
        Request onSearchRequest = new Request();
        Message objMessage = new Message();
        objMessage.setCatalog(catalog);
        onSearchRequest.setMessage(objMessage);
        onSearchRequest.setContext(context);

        return webClient.post()
                .uri("https://bff19297-c961-4269-9b01-02e6e2b9d557.mock.pstmn.io/on_search")
                .body(BodyInserters.fromValue(onSearchRequest))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("RequesterService::error::onErrorResume::" + error);
                    return Mono.empty(); //TODO:Add appropriate response
                });
    }

    Mono<String> run(Request request) {

        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PROVIDER;

        Map<String, String> searchParams = getSearchParams(request);
        String searchString = buildSearchString(searchParams);
        WebClient webClient = WebClient.create(searchEndPoint + searchString);
        return webClient.get()
                .headers(headers -> headers.setBasicAuth("Admin", "Admin123"))
                .exchangeToMono(clientResponse -> {
                    return clientResponse.bodyToMono(String.class);
                });
    }

    private Map<String,String> getSearchParams(Request request) {

        Map<String,String> listOfParams = new HashMap<String, String>();
        String valueName = request.getMessage().getIntent().getFulfillment().getAgent().getName() ;
        String valueHPRID = request.getMessage().getIntent().getFulfillment().getAgent().getId();
        Map<String, String> valueTags = request.getMessage().getIntent().getFulfillment().getAgent().getTags();

        if(valueName != null) {
            listOfParams.put("name", valueName);
        }

        if(valueName == null)
        {
            listOfParams.put("name", "");
        }

        if(valueHPRID != null)
        {
            listOfParams.put("hprid", valueHPRID);
        }

        return listOfParams;
    }

    public static Response generateAck(ObjectMapper mapper) {

        String jsonString;
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

    private String buildSearchString(Map<String,String> params)
    {
        String searchString = "?v=full&q=";
        String valueName = params.getOrDefault("name", "");
        return searchString+valueName;
    }

}
