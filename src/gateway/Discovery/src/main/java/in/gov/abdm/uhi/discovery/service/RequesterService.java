package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.common.dto.HeaderDTO;
import in.gov.abdm.uhi.common.dto.Request;
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
    @Value("${spring.application.isHeaderEnabled}")
    Boolean isHeaderEnabled;
    @Value("${spring.application.gateway_pubKey}")
    String gateway_pubKey;
    @Value("${spring.application.gateway_privKey}")
    String gateway_privKey;

    public RequesterService(NetworkRegistryService registryService, AppConfig appConfig, GatewayUtility gatewayUtil, Crypt crypt, DiscoveryConfig discoveryConfig, HSPAService hspaService) {
        this.registryService = registryService;
        this.appConfig = appConfig;
        this.gatewayUtil = gatewayUtil;
        this.crypt = crypt;
        this.discoveryConfig = discoveryConfig;
        this.HSPAService = hspaService;
    }

    public Mono<String> processor(@RequestBody String req, @RequestHeader Map<String, String> headers)
            throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {

        Request request = appConfig.objectMapper().readValue(req, Request.class);

        String authHeader = headers.get(GlobalConstants.AUTHORIZATION);
        LOGGER.info("{} | Authorization |{}", request.getContext().getMessageId(), authHeader);
        gatewayUtil.checkAuthHeader(headers, request);


        HeaderDTO params = crypt.extractAuthorizationParams(GlobalConstants.AUTHORIZATION, headers);
        Mono<String> subs = registryService.getParticipantsDetails(request.getContext(), params);
        return subs.flatMap(sub -> {
            try {
                boolean ifContainsNack = sub.contains("NACK");
                if(!ifContainsNack) {
                    return registryService.validateParticipant(request, headers, req, sub);
                }
                else {
                   return Mono.just(sub);
                }
            } catch (NoSuchAlgorithmException | NoSuchProviderException | SignatureException | JsonProcessingException |
                     InvalidKeySpecException | InvalidKeyException e) {
                gatewayUtil.logErrorMessageForKibana(request,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                return Mono.error(new GatewayException(e.getMessage()));
            }
        });
    }


}
