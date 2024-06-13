package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.common.dto.HeaderDTO;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Subscriber;
import in.gov.abdm.uhi.discovery.configuration.AppConfig;
import in.gov.abdm.uhi.discovery.configuration.DiscoveryConfig;
import in.gov.abdm.uhi.discovery.exception.GatewayError;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.Crypt;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.Arrays;
import java.util.Map;

@Service
public class RequesterService {

    private static final Logger LOGGER = LoggerFactory.getLogger(RequesterService.class);
    public static final String PROCESSOR = "::processor()";

    final
    NetworkRegistryService registryService;

    final
    AppConfig appConfig;

    final
    GatewayUtility gatewayUtil;

    final
    Crypt crypt;


    final
    DiscoveryConfig discoveryConfig;
    final
    HSPAService HSPAService;
    final
    AuditService auditService;
    @Value("${spring.application.isHeaderEnabled}")
    Boolean isHeaderEnabled;
    @Value("${spring.application.gateway_pubKey}")
    String gateway_pubKey;
    @Value("${spring.application.gateway_privKey}")
    String gateway_privKey;

    public RequesterService(NetworkRegistryService registryService, AppConfig appConfig, GatewayUtility gatewayUtil, Crypt crypt, DiscoveryConfig discoveryConfig, HSPAService hspaService, AuditService auditService) {
        this.registryService = registryService;
        this.appConfig = appConfig;
        this.gatewayUtil = gatewayUtil;
        this.crypt = crypt;
        this.discoveryConfig = discoveryConfig;
        this.HSPAService = hspaService;
        this.auditService = auditService;
    }

    public Mono<String> processor(@RequestBody String req, @RequestHeader Map<String, String> headers, String requestId)
            throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();

        LOGGER.debug("SEARCH ENDPOINT search() processor() before objectMapper {} | Request ID: {} | Converting request to Request object...", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId);
        Request request = appConfig.objectMapper().readValue(req, Request.class);
        LOGGER.debug("SEARCH ENDPOINT search() processor() {} | Request ID: {}: | request converted | Transaction ID: {} | Consumer URI: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getTransactionId(), request.getContext().getConsumerUri());
        String authHeader = headers.get(GlobalConstants.AUTHORIZATION);
        LOGGER.info("80 SEARCH ENDPOINT search() processor() {} | Request ID: {} | Message ID: {} | Checking Authorization: {} | Transaction ID: {} | request body : {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getMessageId(), authHeader, request.getContext().getTransactionId(),request.getMessage().getIntent()==null?"":request.getMessage().getIntent().getLocation());
        gatewayUtil.checkAuthHeader(headers, request, requestId);
        final String headersString = String.valueOf(authHeader);
        HeaderDTO params = crypt.extractAuthorizationParams(GlobalConstants.AUTHORIZATION, headers);
        Mono<String> subs = registryService.getParticipantsDetails(request.getContext(), params, requestId,request);
        return subs.flatMap(sub -> {
            try {
                boolean ifContainsNack = sub.contains("NACK");
                if(!ifContainsNack) {
                    LOGGER.info("90 SEARCH ENDPOINT search() processor() {} | Request ID: {} | Participant details retrieved, validating participant...  | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getTransactionId());
                    if(request != null){
                        LOGGER.debug("92 SEARCH ENDPOINT search() processor() CALLING AUDIT SERVICE ------ Transaction ID: {} | Action: {} | Transaction ID: {} | ",request.getContext().getTransactionId(), request.getContext().getAction(), request.getContext().getTransactionId());
                        auditService.auditServiceCall(request, headersString);
                    }
                    return registryService.validateParticipant(request, headers, req, sub, requestId);
                }
                else {
                    LOGGER.info("SEARCH ENDPOINT search() processor() {} | Request ID: {} | Failed: Participant details retrieval failed {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, sub, request.getContext().getTransactionId());
                    return Mono.just(sub);
                }
            } catch (NoSuchAlgorithmException | NoSuchProviderException | SignatureException | JsonProcessingException |
                     InvalidKeySpecException | InvalidKeyException e) {
                LOGGER.info("SEARCH ENDPOINT search() processor()  Error: {} | Request ID: {} | Request {} | Exception: {} | Code: {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request, e.getMessage(), GatewayError.INVALID_KEY.getCode(), request.getContext().getTransactionId());
                gatewayUtil.logErrorMessageForKibana(request,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                return Mono.error(new GatewayException(e.getMessage()));
            }
        });

    }
}
