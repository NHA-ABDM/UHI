
/*
 * Copyright 2022  NHA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.discovery.controller.ResponderController;
import in.gov.abdm.uhi.discovery.entity.ListofSubscribers;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.entity.Subscriber;
import in.gov.abdm.uhi.discovery.service.beans.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheConfig;
import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

@Service
@CacheConfig(cacheNames = {"NetworkRegistry"})
public class RequesterService {

    @Autowired
    private ReactiveCircuitBreakerFactory circuitBreakerFactory;

    public static final String searchAPI = "/search";
    public static final String lookupAPI = "/lookup";

    @Value("${spring.application.registryurl}")
    String registry_url;


    WebClient webClient = WebClient.create();

    private static final Logger LOGGER = LogManager.getLogger(ResponderController.class);

    public Flux<String> processor(@RequestBody String request) throws JsonProcessingException {

        Mono<String> getData = circuitBreakerWrapper(request);
        LOGGER.info((getData.toString()));
        return getData
                .flatMapIterable(this::extractURIList)
                .flatMap(uris -> sendSingleWithMessage(uris, request));
    }


    public Mono<String> circuitBreakerWrapper(String body) throws JsonProcessingException {
        return circuitBreakerFactory.create("lookup").run(sendSingleWithBody(body), t -> {
            LOGGER.warn("Lookup called failed", t);
            return CircuitBreakerError();
        });
    }

    public Mono<String> sendSingleWithBody(String body) throws JsonProcessingException {

        ObjectMapper obj = new ObjectMapper();
        RequestRoot request = obj.readValue(body, RequestRoot.class);
        Subscriber subscriber = transformSubscriber(request);

        return webClient.post()
                .uri(registry_url + lookupAPI)
                .body(BodyInserters.fromValue(subscriber))
                .retrieve()
                .bodyToMono(String.class)
                .retryWhen(Retry.fixedDelay(3, Duration.ofSeconds(5)));
//              .onErrorResume(error -> {
//                    LOGGER.error("RequesterService::error::sendSingleWithBody::" + error);
//                    return Mono.just("Failed Lookup"); //TODO:Add appropriate response
//              });

    }


    private Subscriber transformSubscriber(RequestRoot request) {

        Subscriber subscriber = new Subscriber();
        ContextRoot context = request.getContext();

        subscriber.setCountry(context.getCountry());
        subscriber.setCity(context.getCity());
        subscriber.setDomain(context.getDomain());
        subscriber.setType("HSPA");
        subscriber.setStatus("SUBSCRIBED");

        return subscriber;

    }

    private List<String> extractURIList(String request) {

        List<String> listValue = new ArrayList<String>();
        ObjectMapper obj = new ObjectMapper();
        try {

            ListofSubscribers listOfSubscribers = null;
            listOfSubscribers = obj.readValue(request, ListofSubscribers.class);
            listOfSubscribers.message.forEach(data -> listValue.add(data.getUrl()));
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage());
        }
        return listValue;

    }

    private Mono<String> sendSingleWithMessage(String uri, String request) {

        LOGGER.info("RequesterService::info::sendSingle::" + uri);

        Mono<String> response = null;
        try {

            ObjectMapper obj = new ObjectMapper();
            RequestRoot body = obj.readValue(request, RequestRoot.class);

            response = webClient.post()
                    .uri(uri + "/search")
                    .body(BodyInserters.fromValue(body))
                    .retrieve()
                    .bodyToMono(String.class)
                    .retry(3)
                    .onErrorResume(error -> {
                        LOGGER.error("RequesterService::error::onErrorResume::" + error);
                        return ErrorMessage_CircuitBreaker; //TODO:Add appropriate response
                    });
        } catch (Exception ex) {
            response = Mono.just(ex.getMessage());
            LOGGER.error("RequesterService::error::catchBlock::" + ex.getMessage());
        }
        return response;
    }

    private Mono<String> CircuitBreakerError() {
        ListofSubscribers res = new ListofSubscribers();
        res.message = new ArrayList<>();
        return Mono.just("res");
    }


    private final Mono<String> ErrorMessage_CircuitBreaker = Mono.just("{\n" +
            "    \"message\": {\n" +
            "        \"ack\": {\n" +
            "            \"status\": \"NACK\"\n" +
            "        }\n" +
            "    },\n" +
            "    \"error\": {\n" +
            "        \"type\": \"ResponseException\",\n" +
            "        \"code\": \"404\",\n" +
            "        \"path\": \"string\",\n" +
            "        \"message\": \"Endpoint not reachable.\"\n" +
            "    }\n" +
            "}");
}
