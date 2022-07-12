
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

import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.controller.ResponderController;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.net.URISyntaxException;

@Service
public class ResponderService {

	@Autowired
	SignatureUtility signatureUtility;
	
	@Autowired
	GatewayUtility gatewayUtil;
	
	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;
	
    private static final Logger LOGGER = LogManager.getLogger(ResponderController.class);

    public Mono<String> processor(RequestRoot request) throws URISyntaxException {

        Mono<String> onSearchForward = null;
        String targetURI = "";
       
        WebClient client = WebClient.create(targetURI);
        try {
        	 targetURI = request.getContext().getConsumerUri();
        	 LOGGER.info("{} | Consumer ID |{}",request.getContext().getMessageId(),targetURI);
            onSearchForward = client.post().uri(targetURI+"/on_search")
                    .contentType(MediaType.APPLICATION_JSON)
                    .accept(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(request))
                    .header("X-Gateway-Authorization", isHeaderEnabled?signatureUtility.getGatewayHeaders(request):"")
                    .retrieve()
                    .onStatus(HttpStatus::is4xxClientError,
					        resp -> resp.bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
					.onStatus(HttpStatus::is5xxServerError,
					        resp -> resp.bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
                    .bodyToMono(Response.class)
                    .onErrorResume(error -> {
						LOGGER.error("{} Responder Service::error::onErrorResume::{}",request.getContext().getMessageId(), error);
                        return gatewayUtil.generateNack(error); 
                    }).thenReturn(gatewayUtil.generateAck()).log();
        	
        } catch (Exception ex) {

            throw ex;
        }
        return onSearchForward;
    }

}
