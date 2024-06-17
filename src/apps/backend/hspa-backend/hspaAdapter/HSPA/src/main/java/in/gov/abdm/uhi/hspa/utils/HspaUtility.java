package in.gov.abdm.uhi.hspa.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;

import in.gov.abdm.uhi.hspa.exceptions.AuthHeaderNotFoundError;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.sql.Timestamp;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Component
public class HspaUtility {
    private static final Logger LOGGER = LoggerFactory.getLogger(HspaUtility.class);

    final
    ObjectMapper objectMapper;

    final
    Crypt crypt;

    @Value("${spring.hspa.pubKeyId}")
    private String headerPublicKeyId;
    @Value("${spring.hspa.privKey}")
    private String headerPrivateKey;
    @Value("${spring.hspa.subsId}")
    private String subscriberId;
    @Value("${spring.hspa.pubKey}")
    private String publicKey;
    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    @Value("${spring.gateway.publicKey}")
    private String gatewayPublicKey;

    @Value("${spring.header.encrypt.subscriberCity}")
    private String subscriberCity;
    @Value("${spring.header.encrypt.domain}")
    private String subscriberDomain;
    @Value("${spring.header.encrypt.country}")
    private String subscriberCountry;

    @Qualifier("normalWebClient")
    @Autowired
    WebClient webClient;

    @Value("${spring.application.registry_url_public}")
    private String registryUrl;


    public HspaUtility(ObjectMapper objectMapper, Crypt crypt) {
        this.objectMapper = objectMapper;
        this.crypt = crypt;
    }


    public static void logErrorMessageForKibana(Request request, String error, String className) {
        LOGGER.error(
                "{}::error::onErrorResume::created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, domain:{}, city:{}, action:{}, Error:{}",
                className,new Timestamp(System.currentTimeMillis()), request.getContext().getTransactionId(),
                request.getContext().getMessageId(), request.getContext().getConsumerId(),
                request.getContext().getDomain(), request.getContext().getCity(), request.getContext().getAction(),
               error);
    }

    public static void checkAuthHeader(Map<String, String> headers, Request request) {
        if (!headers.containsKey(GlobalConstants.AUTHORIZATION.toLowerCase())) {
            HspaUtility.logErrorMessageForKibana(request, GatewayError.AUTH_HEADER_NOT_FOUND.getMessage(), GlobalConstants.GATEWAY_UTILITY);
            throw new AuthHeaderNotFoundError("Auth header not found.");
        }
    }

    public void checkXGatewayHeader(Map<String, String> headers, Request request) {
        if(Boolean.parseBoolean(isHeaderEnabled) && (!headers.containsKey(GlobalConstants.X_GATEWAY_AUTHORIZATION.toLowerCase()))) {
                HspaUtility.logErrorMessageForKibana(request, GatewayError.AUTH_HEADER_NOT_FOUND.getMessage(), GlobalConstants.GATEWAY_UTILITY);
                throw new AuthHeaderNotFoundError("Auth header not found.");

        }
    }

    public boolean getHeaderVerificationResult(String request, Map<String, String> headers, Request objRequest, String headerName, String publicKey) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException, SignatureException, InvalidKeyException {
        if(Boolean.parseBoolean(isHeaderEnabled)) {
            HeaderDTO headerDTO = crypt.extractAuthorizationParams(headerName, headers, objRequest);
            String hashedSigningString = crypt.generateBlakeHash(
                    crypt.getSigningString(Long.parseLong(headerDTO.getCreated()), Long.parseLong(headerDTO.getExpires()), request));
            return crypt.verifySignature(hashedSigningString, headerDTO.getSignature(), GlobalConstants.ED_25519, Crypt.getPublicKey(GlobalConstants.ED_25519, Base64.getDecoder().decode(publicKey)));
        }
        else{
            return true;
        }
    }

    public Mono<List<Subscriber>> getSubscriberDetailsOfEua(Request responseClass, String euaSubsId, String euaPubKeyId) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        if(Boolean.parseBoolean(isHeaderEnabled)) {
            Subscriber subscriber = Subscriber.builder().subscriber_id(euaSubsId).type(GlobalConstants.EUA).city(responseClass.getContext().getCity()).pub_key_id(euaPubKeyId).domain(responseClass.getContext().getDomain()).country(responseClass.getContext().getCountry()).subscriber_url(responseClass.getContext().getConsumerUri()).build();
            LOGGER.info("{} | {}::GatewayUtility:: EUA Subscriber generated for lookup:: {}", responseClass.getContext().getMessageId(), this.getClass().getName(), objectMapper.writeValueAsString(subscriber));
            String authHeader = crypt.generateAuthorizationParams(subscriberId, headerPublicKeyId, objectMapper.writeValueAsString(subscriber), Crypt.getPrivateKey("Ed25519", Base64.getDecoder().decode(headerPrivateKey)));
            LOGGER.info("{} | {}::GatewayUtility:: HSPA header generated for lookup:: {}", responseClass.getContext().getMessageId(), this.getClass().getName(), authHeader);
            return processLookupCall(responseClass, subscriber, authHeader);
        }
        else {
            return Mono.empty();
        }
    }

    public Map<String, String> getKeyIdMapFromHeaders(Map<String, String> headers, Request objRequest) throws JsonProcessingException {
        if(Boolean.parseBoolean(isHeaderEnabled)) {
            HeaderDTO headerDto = crypt.extractAuthorizationParams(GlobalConstants.AUTHORIZATION.toLowerCase(), headers, objRequest);
            return crypt.extarctKeyId(headerDto.getKeyId());
        }
        else{
            return Collections.emptyMap();
        }
    }

    private Mono<List<Subscriber>> processLookupCall(Request responseClass, Subscriber subscriber, String authHeader) {
        return this.webClient.post().uri(registryUrl)
                .header(GlobalConstants.AUTHORIZATION, authHeader)
                .body(BodyInserters.fromValue(subscriber))
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<List<Subscriber>>() {})
                .onErrorResume(error -> {
                    LOGGER.error("{} | {} :: processResponse::error:: {}", responseClass.getContext().getMessageId(),this.getClass().getName(),error.getLocalizedMessage());
                    return Mono.error(new HspaException(error.getLocalizedMessage()));
                });
    }

    public boolean verifyHeaders(Request responseClass, Map<String, String> httpRequestHeaders, String headerName, String publicKey, String request) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException {
        if (!Boolean.parseBoolean(isHeaderEnabled)) {
            return true;
        } else {
            String headersString;
            headersString = httpRequestHeaders.get(headerName);
            LOGGER.info("{}|Header is ->>>>>>>> {}", responseClass.getContext().getMessageId(), headersString);
            HeaderDTO headerParams = crypt.extractAuthorizationParams(headerName, httpRequestHeaders, responseClass);
            String hashedSigningString = crypt.generateBlakeHash(
                    crypt.getSigningString(Long.parseLong(headerParams.getCreated()), Long.parseLong(headerParams.getExpires()), request));
            if (crypt.verifySignature(hashedSigningString, headerParams.getSignature(), GlobalConstants.ED_25519, Crypt.getPublicKey(GlobalConstants.ED_25519, Base64.getDecoder().decode(publicKey)))) {
                LOGGER.info("{} | {}::gatewayToEuaConsumer::Header verification successful", responseClass.getContext().getMessageId(), this.getClass().getName());
                return true;
            } else {
                LOGGER.error("{} | {}::gatewayToEuaConsumer::Header verification failed", responseClass.getContext().getMessageId(), this.getClass().getName());
                return false;
            }
        }
    }
}
