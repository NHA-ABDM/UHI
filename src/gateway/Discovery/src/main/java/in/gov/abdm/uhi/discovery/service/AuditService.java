package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Ack;
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
import org.bouncycastle.cert.ocsp.Req;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
public class AuditService {
    private static final Logger LOGGER = LogManager.getLogger(AuditService.class);
    @Value("${spring.application.audit_url}")
    String audit_url;
    final
    AppConfig appConfig;
    final
    WebClient getWebClient;

    final
    Crypt crypt;

    final
    NetworkRegistryService registryService;

    final
    ObjectMapper objectMapper;

    final
    HSPAService hspaService;

    Request reqroot;
    final
    GatewayUtility gatewayUtil;
    @Autowired
    private RestTemplate restTemplate;
    public AuditService(AppConfig appConfig, WebClient getWebClient, GatewayUtility gatewayUtil,Crypt crypt,NetworkRegistryService registryService,ObjectMapper objectMapper,HSPAService hspaService){
        this.getWebClient = getWebClient;
        this.gatewayUtil = gatewayUtil;
        this.appConfig = appConfig;
        this.crypt=crypt;
        this.registryService=registryService;
        this.objectMapper=objectMapper;
        this.hspaService=hspaService;
    }
    private String getEndpoint(String context){
        if(GlobalConstants.ON_SEARCH.toLowerCase().equals(context)){
            return GlobalConstants.ON_SEARCH_ENDPOINT;
        }else if(GlobalConstants.SEARCH.toLowerCase().equals(context)){
            return GlobalConstants.SEARCH_ENDPOINT;
        }else if(GlobalConstants.SEARCH_AUDIT.toLowerCase().equals(context)) {
            return GlobalConstants.SEARCH_AUDIT_ENDPOINT;
        }else if(GlobalConstants.ON_STATUS_AUDIT.toLowerCase().equals(context)){
            return GlobalConstants.ON_STATUS_AUDIT_ENDPOINT;
        } else if(GlobalConstants.ON_CANCEL_AUDIT.toLowerCase().equals(context)) {
            return GlobalConstants.ON_CANCEL_AUDIT_ENDPOINT;
        } else{
            return GlobalConstants.ON_CONFIRM_AUDIT_ENDPOINT;
        }
    }

    @Async
    public CompletableFuture<Void> auditServiceCall(Request request, String headersString){
        String endpoint = getEndpoint(request.getContext().getAction());
        try{
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set(GlobalConstants.X_GATEWAY_AUTHORIZATION, headersString);
            RequestEntity<Request> requestEntity = new RequestEntity<>(request, headers, HttpMethod.POST, new URI(audit_url + endpoint));
            restTemplate.exchange(requestEntity, Void.class);
        }catch (Exception exce){
            LOGGER.info("EXCEPTION IN AUDIT CALL: created_on:{}, transaction_id:{}, action:{}",new Timestamp(System.currentTimeMillis()), request.getContext().getTransactionId(), endpoint);
        }
        return CompletableFuture.completedFuture(null);
    }


    public Mono<String> auditProcessor(String strrequest, @RequestHeader Map<String, String> headers, String requestId) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();

        reqroot = new Request();

        LOGGER.info("ON_STATUS onStatus() processor() {} | Request ID: {} | Converting request to Request object...", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId);
        reqroot = appConfig.objectMapper().readValue(strrequest, Request.class);
        LOGGER.info("ON_STATUS onStatus() processor() {} | Request ID: {}: | request converted | Transaction ID: {} | Consumer URI: {} | Provider URI: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getTransactionId(), reqroot.getContext().getConsumerUri(), reqroot.getContext().getProviderUri());

        String action = reqroot.getContext().getAction();
        LOGGER.info("ON_STATUS onStatus() processor() {} | Request ID: {} | Message ID: {} | Checking header Authorization: {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getMessageId(), headers, reqroot.getContext().getTransactionId());
        gatewayUtil.checkAuthHeader(headers, reqroot, requestId);
        HeaderDTO params = crypt.extractAuthorizationParams(GlobalConstants.AUTHORIZATION, headers);
        Mono<String> subs = registryService.getParticipantsDetails(reqroot.getContext(), params, requestId,reqroot);
        return subs.flatMap(sub -> {
            try {
                LOGGER.info("ON_STATUS onStatus() processor() {} | Request ID: {} | Participant details retrieved, validating participant...  | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getTransactionId());
                return registryService.validateParticipant(reqroot, headers, strrequest, sub, requestId).flatMap(
                        validationResponse ->
                        {
                            try {
                                LOGGER.info("ON_STATUS onStatus() processor(){} | Request ID: {} | Processing call to EUA | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot.getContext().getTransactionId());
                                return processIfValidationSuccessful(strrequest, validationResponse);
                            } catch (NoSuchAlgorithmException | NoSuchProviderException | JsonProcessingException |
                                     InvalidKeySpecException e) {
                                LOGGER.info("ON_STATUS onStatus() processor() Error: {} | Request ID: {} | Request {} | Exception: {} | Code: {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot, e.getMessage(), GatewayError.INVALID_KEY.getCode(), reqroot.getContext().getTransactionId());
                                gatewayUtil.logErrorMessageForKibana(reqroot,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                                return Mono.error(new GatewayException(e.getMessage()));
                            }
                        }
                );
            } catch (NoSuchAlgorithmException | NoSuchProviderException | SignatureException | JsonProcessingException |
                     InvalidKeySpecException | InvalidKeyException e) {
                LOGGER.info("ON_STATUS onStatus() processor() Error: {} | Request ID: {} | Request {} | Exception: {} | Code: {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, reqroot, e.getMessage(), GatewayError.INVALID_KEY.getCode(), reqroot.getContext().getTransactionId());
                gatewayUtil.logErrorMessageForKibana(reqroot,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                return Mono.error(new GatewayException(e.getMessage()));
            }
        });
    }

    private Mono<String> processIfValidationSuccessful(String strrequest, String validationResponse) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {
        Request request = objectMapper.readValue(strrequest, Request.class);
        boolean isValidationSuccessful = !validationResponse.contains("NACK");
        if(isValidationSuccessful) {
            String authHeaders;
            authHeaders = hspaService.getHspaHeaders(strrequest);
            String headersString = String.valueOf(authHeaders);
            LOGGER.info("ON_STATUS onStatus() processor() processEuaCallIfValidationSuccessful() Responder headersString|{} | MessageId {} | Consumer ID |{} | Transaction ID: {} ", headersString, reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerUri(), reqroot.getContext().getTransactionId());
            if(request != null){
                LOGGER.info("ON_STATUS onStatus() processor() processEuaCallIfValidationSuccessful() CALLING AUDIT SERVICE ------ Transaction ID: {} | Action: {}",request.getContext().getTransactionId(), request.getContext().getAction());
               auditServiceCall(request, headersString);
            }
        }
        LOGGER.info("ON_STATUS onStatus() processor() processEuaCallIfValidationSuccessful() Validation response {}:: messageId is {} | Transaction ID: {} ", validationResponse, request.getContext().getMessageId(), request.getContext().getTransactionId());
        return Mono.just(validationResponse);
    }

}
