
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
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.net.URISyntaxException;

@Service
public class ResponderService {

    private static final Logger LOGGER = LogManager.getLogger(ResponderController.class);

    public Mono<String> processor(String request) throws URISyntaxException {

        Mono<String> onSearchForward = null;
        ObjectMapper mapper = new ObjectMapper();
        RequestRoot message = null;
        String targetURI = "";
        try {
            message = mapper.readValue(request, RequestRoot.class);
            targetURI = message.getContext().getConsumer_uri();

        } catch (JsonProcessingException ex) {

            LOGGER.error("RequesterService::error::processor::" + ex);
        }

        WebClient client = WebClient.create(targetURI);
        try {
            onSearchForward = client.post().uri("/on_search")
                    // .header("Authorization", "Bearer MY_SECRET_TOKEN") TODO: Add appropriate
                    // header
                    .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(message)).retrieve().bodyToMono(String.class)
                    .onErrorResume(error -> {
                        LOGGER.error("ResponderService::error::onSearchForward::" + error);
                        return Mono.just("Failed on_search request"); //TODO:Add appropriate response
                    });

        } catch (Exception ex) {

            throw ex;
        }
        return onSearchForward;
    }

}
