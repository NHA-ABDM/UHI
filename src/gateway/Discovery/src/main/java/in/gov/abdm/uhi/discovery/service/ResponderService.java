
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
    AuditService auditService;

    final
    ObjectMapper objectMapper;
    @Value("${spring.application.isHeaderEnabled}")
    Boolean isHeaderEnabled;
    Request reqroot;

    public ResponderService(AppConfig appConfig, WebClient getWebClient, GatewayUtility gatewayUtil, HSPAService hspaService, Crypt crypt, NetworkRegistryService registryService, ObjectMapper objectMapper, AuditService auditService) {
        this.appConfig = appConfig;
        this.getWebClient = getWebClient;
        this.gatewayUtil = gatewayUtil;
        this.hspaService = hspaService;
        this.crypt = crypt;
        this.registryService = registryService;
        this.objectMapper = objectMapper;
        this.auditService = auditService;
    }

    public Mono<String> processor(String strrequest, @RequestHeader Map<String, String> headers, String requestId) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();

        reqroot = new Request();

        LOGGER.info("ON_SEARCH onSearch() processor() {} | Request ID: {} | Converting request to Request object...", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId);
        reqroot = appConfig.objectMapper().readValue(strrequest, Request.class);
        LOGGER.info("ON_SEARCH onSearch() processor() {} | Request ID: {}: | request converted | Transaction ID: {} | Consumer URI: {} | Provider URI: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getTransactionId(), reqroot.getContext().getConsumerUri(), reqroot.getContext().getProviderUri());

        String action = reqroot.getContext().getAction();
        LOGGER.info("ON_SEARCH onSearch() processor() {} | Request ID: {} | Message ID: {} | Checking header Authorization: {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getMessageId(), headers, reqroot.getContext().getTransactionId());
        gatewayUtil.checkAuthHeader(headers, reqroot, requestId);
        HeaderDTO params = crypt.extractAuthorizationParams(GlobalConstants.AUTHORIZATION, headers);
        Mono<String> subs = registryService.getParticipantsDetailsForOnSearch(reqroot.getContext(), params, requestId,reqroot);
        return subs.flatMap(sub -> {
            try {
                boolean ifContainsNack = sub.contains("NACK");
                if (!ifContainsNack) {
                    LOGGER.info("ON_SEARCH onSearch() processor() {} | Request ID: {} | Participant details retrieved, validating participant...  | Transaction ID: {} | ", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getTransactionId());
                    return registryService.validateParticipant(reqroot, headers, strrequest, sub, requestId).flatMap(
                            validationResponse ->
                            {
                                try {
                                    LOGGER.info("ON_SEARCH onSearch() processor(){} | Request ID: {} | Processing call to EUA | Transaction ID: {} | ", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getTransactionId());
                                    return processEuaCallIfValidationSuccessful(strrequest, validationResponse);
                                } catch (NoSuchAlgorithmException | NoSuchProviderException | JsonProcessingException |
                                         InvalidKeySpecException e) {
                                    LOGGER.info("ON_SEARCH onSearch() processor() Error: {} | Request ID: {} | Request {} | Exception: {} | Code: {} | Transaction ID: {} | ", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot, e.getMessage(), GatewayError.INVALID_KEY.getCode(), reqroot.getContext().getTransactionId());
                                    gatewayUtil.logErrorMessageForKibana(reqroot, e.getMessage(), GatewayError.INVALID_KEY.getCode());
                                    return Mono.error(new GatewayException(e.getMessage()));
                                }
                            }

                    );
                }
                    return Mono.just(sub);

                } catch
                (NoSuchAlgorithmException | NoSuchProviderException | SignatureException | JsonProcessingException |
                        InvalidKeySpecException | InvalidKeyException e){
                    LOGGER.info("ON_SEARCH onSearch() processor() Error: {} | Request ID: {} | Request {} | Exception: {} | Code: {} | Transaction ID: {} | ", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot, e.getMessage(), GatewayError.INVALID_KEY.getCode(), reqroot.getContext().getTransactionId());
                    gatewayUtil.logErrorMessageForKibana(reqroot, e.getMessage(), GatewayError.INVALID_KEY.getCode());
                    return Mono.error(new GatewayException(e.getMessage()));
                }

        });
    }

    private Mono<String> processEuaCallIfValidationSuccessful(String strrequest, String validationResponse) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {

        Request request = objectMapper.readValue(strrequest, Request.class);
        boolean isValidationSuccessful = !validationResponse.contains("NACK");
        if(isValidationSuccessful) {
                String authHeaders;
                authHeaders = hspaService.getHspaHeaders(strrequest);
                String headersString = String.valueOf(authHeaders);
                LOGGER.info("ON_SEARCH onSearch() processor() processEuaCallIfValidationSuccessful() Responder headersString|{} | MessageId {} | Consumer ID |{} | Transaction ID: {} ", headersString, reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerUri(), reqroot.getContext().getTransactionId());
                if(request != null){
                    LOGGER.info("ON_SEARCH onSearch() processor() processEuaCallIfValidationSuccessful() CALLING AUDIT SERVICE ------ Transaction ID: {} | Action: {}",request.getContext().getTransactionId(), request.getContext().getAction());
                    auditService.auditServiceCall(request, headersString);
                }
                return euaWebclientCall(strrequest, reqroot.getContext().getConsumerUri(), headersString, GlobalConstants.ON_SEARCH_ENDPOINT);
            }
        LOGGER.info("ON_SEARCH onSearch() processor() processEuaCallIfValidationSuccessful() Validation response {}:: messageId is {} | Transaction ID: {} ", validationResponse, request.getContext().getMessageId(), request.getContext().getTransactionId());
        return Mono.just(validationResponse);
    }

    private Mono<String> generateInternalServerError() {
        return Mono.error(new GatewayException("Internal Server Error"));
    }

    private Mono<String> euaWebclientCall(String strrequest, String targetURI, String headersString, String endpoint) throws JsonProcessingException {
        Mono<String> onSearchForward;
        onSearchForward = getWebClient.post().uri(targetURI + endpoint).contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(strrequest))
                .header(GlobalConstants.X_GATEWAY_AUTHORIZATION, headersString)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        resp -> resp.bodyToMono(String.class)
                                .flatMap(error -> {
                                    LOGGER.error("155 euaWebclientCall() 4xx Server Error Response: {} | target {}", error,targetURI+endpoint);
                                    return Mono.error(new GatewayException(error));
                                }))
                .onStatus(HttpStatus::is5xxServerError,
                        resp -> resp
                                .bodyToMono(String.class).flatMap(error -> {
                                    LOGGER.error("161 euaWebclientCall() 5xx Server Error Response: {}| target {}", error,targetURI+endpoint);
                                    return Mono.error(new GatewayException(error));
                                }))
                .bodyToMono(String.class)
                .doOnSuccess(p -> LOGGER.info(
                        "ON_SEARCH onSearch() processor() processEuaCallIfValidationSuccessful() euaWebclientCall() created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Response:{} endpoint {} payload {}",
                        new Timestamp(System.currentTimeMillis()), reqroot.getContext().getTransactionId(),
                        reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerId(),
                        reqroot.getContext().getProviderId(), reqroot.getContext().getDomain(),
                        reqroot.getContext().getCity(), reqroot.getContext().getAction(), p,targetURI+endpoint,strrequest))
                .onErrorResume(error -> {
                    LOGGER.error("5xx Server Error Response: {}", error);
                    gatewayUtil.logErrorMessageForKibana(reqroot,error.getMessage(), GatewayError.INTERNAL_SERVER_ERROR.getCode());
                    return generateInternalServerError();
                }).log().thenReturn(gatewayUtil.generateAck());
        return onSearchForward;
    }
}
