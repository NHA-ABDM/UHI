//package in.gov.abdm.uhi.hspa.service;
//
//        import com.fasterxml.jackson.core.JsonProcessingException;
//        import com.fasterxml.jackson.databind.ObjectMapper;
//        import in.gov.abdm.uhi.common.dto.*;
//        import in.gov.abdm.uhi.common.dto.Error;
//        import in.gov.abdm.uhi.hspa.models.Subscriber;
//        import org.apache.logging.log4j.LogManager;
//        import org.apache.logging.log4j.Logger;
//        import org.springframework.beans.factory.annotation.Autowired;
//        import org.springframework.beans.factory.annotation.Value;
//        import org.springframework.cache.annotation.CacheConfig;
//        import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
//        import org.springframework.stereotype.Service;
//        import org.springframework.web.bind.annotation.RequestBody;
//        import org.springframework.web.reactive.function.BodyInserters;
//        import org.springframework.web.reactive.function.client.WebClient;
//        import reactor.core.publisher.Flux;
//        import reactor.core.publisher.Mono;
//        import reactor.util.retry.Retry;
//
//        import java.time.Duration;
//        import java.util.ArrayList;
//        import java.util.List;
//
//@Service
//@CacheConfig(cacheNames = {"NetworkRegistry"})
//public class NetworkRegistryService {
//
//
//    @Autowired
//    private ReactiveCircuitBreakerFactory circuitBreakerFactory;
//
//    public static final String lookupAPI = "/lookup";
//
//    @Value("${spring.application.registryurl}")
//    String registry_url;
//
//    @Autowired
//    ObjectMapper mapper;
//
//    WebClient webClient = WebClient.create();
//
//    private static final Logger LOGGER = LogManager.getLogger(NetworkRegistryService.class);
//
//    public Flux<String> processor(@RequestBody String request) throws JsonProcessingException {
//
//        Mono<String> getData =  circuitBreakerWrapper(request);
//        LOGGER.info((getData.toString()));
//        return getData
//                .flatMapIterable(this::extractURIList)
//                .flatMap(uris -> sendSingleWithMessage(uris, request));
//    }
//
//
//    public Mono<String> circuitBreakerWrapper(String body) throws JsonProcessingException {
//        return circuitBreakerFactory.create("lookup").run(sendSingleWithBody(body), t -> {
//            LOGGER.warn("Lookup called failed", t);
//            return CircuitBreakerError();
//        });
//    }
//
//    public Mono<String> sendSingleWithBody(String body) throws JsonProcessingException {
//
//        ObjectMapper obj = new ObjectMapper();
//        Request request = obj.readValue(body, Request.class);
//        Subscriber subscriber = transformSubscriber(request);
//
//        return webClient.post()
//                .uri(registry_url + lookupAPI)
//                .body(BodyInserters.fromValue(subscriber))
//                .retrieve()
//                .bodyToMono(String.class)
//                .retryWhen(Retry.fixedDelay(3, Duration.ofSeconds(5)));
//    }
//
//    private Subscriber transformSubscriber(Request request) {
//
//        Subscriber subscriber = new Subscriber();
//        Context context = request.getContext();
//
//        subscriber.setCountry(context.getCountry());
//        subscriber.setCity(context.getCity());
//        subscriber.setDomain(context.getDomain());
//        subscriber.setType("HSPA");
//        subscriber.setStatus("SUBSCRIBED");
//
//        return subscriber;
//
//    }
//
//    private List<String> extractURIList(String request) {
//
//        List<String> listValue = new ArrayList<String>();
//        ObjectMapper obj = new ObjectMapper();
//        try {
//
//            ListofSubscribers listOfSubscribers = null;
//            listOfSubscribers = obj.readValue(request, ListofSubscribers.class);
//            listOfSubscribers.message.forEach(data -> listValue.add(data.getUrl()));
//        } catch (Exception ex) {
//            LOGGER.error(ex.getMessage());
//        }
//        return listValue;
//
//    }
//
//    private Mono<String> sendSingleWithMessage(String uri, String request) {
//
//        LOGGER.info("RequesterService::info::sendSingle::" + uri);
//
//        Mono<String> response = null;
//        try {
//
//            ObjectMapper obj = new ObjectMapper();
//            Request body = obj.readValue(request, Request.class);
//
//            response = webClient.post()
//                    .uri(uri + "/search")
//                    .body(BodyInserters.fromValue(body))
//                    .retrieve()
//                    .bodyToMono(String.class)
//                    .retry(3)
//                    .onErrorResume(error -> {
//                        LOGGER.error("RequesterService::error::onErrorResume::" + error);
//                        return Mono.just(generateNack(mapper, error)); //TODO:Add appropriate response
//                    });
//        } catch (Exception ex) {
//            response = Mono.just(ex.getMessage());
//            LOGGER.error("RequesterService::error::catchBlock::" + ex.getMessage());
//        }
//        return response;
//    }
//
//    private static Response generateNack(ObjectMapper mapper, Exception js) {
//
//        MessageAck msz = new MessageAck();
//        Response res = new Response();
//        Ack ack = new Ack();
//        ack.setStatus("NACK");
//        msz.setAck(ack);
//        in.gov.abdm.uhi.common.dto.Error err = new Error();
//        err.setMessage(js.getMessage());
//        err.setType("Select");
//        res.setError(err);
//        res.setMessage(msz);
//        return res;
//    }
//
//
//}
//
