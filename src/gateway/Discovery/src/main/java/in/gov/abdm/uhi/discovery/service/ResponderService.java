
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
import in.gov.abdm.uhi.common.dto.HeaderDTO;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.discovery.configuration.AppConfig;
import in.gov.abdm.uhi.discovery.exception.GatewayError;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.Crypt;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.sql.Timestamp;
import java.util.Map;

@Service
public class ResponderService {

    private static final Logger LOGGER = LogManager.getLogger(ResponderService.class);
    final
    AppConfig appConfig;
    final
    WebClient getWebClient;
    final
    GatewayUtility gatewayUtil;
    final
    HSPAService hspaService;
    final
    Crypt crypt;

    final
    NetworkRegistryService registryService;

    final
    ObjectMapper objectMapper;
    @Value("${spring.application.isHeaderEnabled}")
    Boolean isHeaderEnabled;
    Request reqroot;

    public ResponderService(AppConfig appConfig, WebClient getWebClient, GatewayUtility gatewayUtil, HSPAService hspaService, Crypt crypt, NetworkRegistryService registryService, ObjectMapper objectMapper) {
        this.appConfig = appConfig;
        this.getWebClient = getWebClient;
        this.gatewayUtil = gatewayUtil;
        this.hspaService = hspaService;
        this.crypt = crypt;
        this.registryService = registryService;
        this.objectMapper = objectMapper;
    }

    public Mono<String> processor(String strrequest, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {

        reqroot = new Request();
            reqroot = appConfig.objectMapper().readValue(strrequest, Request.class);

        gatewayUtil.checkAuthHeader(headers, reqroot);

        HeaderDTO params = crypt.extractAuthorizationParams(GlobalConstants.AUTHORIZATION, headers);
        Mono<String> subs = registryService.getParticipantsDetails(reqroot.getContext(), params);
        return subs.flatMap(sub -> {
            try {
                return registryService.validateParticipant(reqroot, headers, strrequest, sub).flatMap(
                        validationResponse ->
                        {
                            try {
                                return processEuaCallIfValidationSuccessful(strrequest, validationResponse);
                            } catch (NoSuchAlgorithmException | NoSuchProviderException | JsonProcessingException |
                                     InvalidKeySpecException e) {
                                gatewayUtil.logErrorMessageForKibana(reqroot,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                                LOGGER.error("{} | RequesterService::processor::{}",reqroot.getContext().getMessageId(), e.getMessage());
                                return Mono.error(new GatewayException(e.getMessage()));
                            }
                        }
                        );
            } catch (NoSuchAlgorithmException | NoSuchProviderException | SignatureException | JsonProcessingException |
                     InvalidKeySpecException | InvalidKeyException e) {
                gatewayUtil.logErrorMessageForKibana(reqroot,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                LOGGER.error("{} | ResponderService::processor::{}",reqroot.getContext().getMessageId(), e.getMessage());
                return Mono.error(new GatewayException(e.getMessage()));
            }
        });
    }

    private Mono<String> processEuaCallIfValidationSuccessful(String strrequest, String validationResponse) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {

        Request request = objectMapper.readValue(strrequest, Request.class);
        boolean isValidationSuccessful = !validationResponse.contains("NACK");
        if(isValidationSuccessful) {
                String authHeaders;

                    authHeaders = hspaService.getHspaHeaders(strrequest);

                String headersString = String.valueOf(authHeaders);
                LOGGER.info("Responder headersString|{}", headersString);
                LOGGER.info("{} | Consumer ID |{}", reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerUri());

               return euaWebclientCall(strrequest, reqroot.getContext().getConsumerUri(), headersString);

            }
        LOGGER.info("Validation response {}:: messageId is {}", validationResponse, request.getContext().getMessageId());
        return Mono.just(validationResponse);
    }

    private Mono<String> generateInternalServerError() {
        return Mono.error(new GatewayException("Internal Server Error"));
    }


    private Mono<String> euaWebclientCall(String strrequest, String targetURI, String headersString) throws JsonProcessingException {
        Mono<String> onSearchForward;
        onSearchForward = getWebClient.post().uri(targetURI + "/on_search").contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(strrequest))
                .header(GlobalConstants.X_GATEWAY_AUTHORIZATION, headersString)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        resp -> resp.bodyToMono(String.class)
                                .flatMap(error -> Mono.error(new GatewayException(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        resp -> resp
                                .bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
                .bodyToMono(String.class)
                .doOnSuccess(p -> LOGGER.info(
                        "created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Response:{}",
                        new Timestamp(System.currentTimeMillis()), reqroot.getContext().getTransactionId(),
                        reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerId(),
                        reqroot.getContext().getProviderId(), reqroot.getContext().getDomain(),
                        reqroot.getContext().getCity(), reqroot.getContext().getAction(), p))
                .onErrorResume(error -> {
                    gatewayUtil.logErrorMessageForKibana(reqroot,error.getMessage(), GatewayError.INTERNAL_SERVER_ERROR.getCode());
                    return generateInternalServerError();
                }).log().thenReturn(gatewayUtil.generateAck());
        return onSearchForward;
    }

}
