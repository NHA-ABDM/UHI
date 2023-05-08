package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.HeaderDTO;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Subscriber;
import in.gov.abdm.uhi.discovery.configuration.AppConfig;
import in.gov.abdm.uhi.discovery.exception.*;
import in.gov.abdm.uhi.discovery.security.Crypt;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Service
public class NetworkRegistryService {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetworkRegistryService.class);

    final
    GatewayUtility gatewayUtil;

    final
    AppConfig appConfig;

    final
    Crypt crypt;
    final
    WebClient getWebClient;
    final
    ObjectMapper objectMapper;
    final
    HSPAService HSPAService;
    private final ReactiveCircuitBreakerFactory circuitBreakerFactory;
    @Value("${spring.application.registry_url_private}")
    String registry_url;
    @Value("${spring.application.registry_url_public}")
    String registry_url_public;

    @Value("${spring.application.gateway_privKey}")
    private String gatewayPrivateKey;

    @Value("${spring.application.gateway_pubKeyId}")
    private String gatewayPubKeyId;

    @Value("${spring.application.gateway_subsId}")
    private String gatewaySubId;


    public NetworkRegistryService(GatewayUtility gatewayUtil, AppConfig appConfig, Crypt crypt, ReactiveCircuitBreakerFactory circuitBreakerFactory, WebClient getWebClient, ObjectMapper objectMapper, HSPAService hspaService) {
        this.gatewayUtil = gatewayUtil;
        this.appConfig = appConfig;
        this.crypt = crypt;
        this.circuitBreakerFactory = circuitBreakerFactory;
        this.getWebClient = getWebClient;
        this.objectMapper = objectMapper;
        this.HSPAService = hspaService;
    }

    Mono<String> validateParticipant(Request request, Map<String, String> headers, String req, String subscriber) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException, JsonProcessingException {
        Mono<String> result = null;

        List<Subscriber> subsList = appConfig.objectMapper().readValue(subscriber, new TypeReference<>() {
        });

        Subscriber subs = subsList.get(0);

        LOGGER.info("{} |EUA/HSPA validation success", request.getContext().getMessageId());

        HeaderDTO headerDTO = objectMapper.readValue(headers.get(GlobalConstants.AUTHORIZATION), HeaderDTO.class);

        String hashedSigningString = crypt.generateBlakeHash(
                crypt.getSigningString(Long.parseLong(headerDTO.getCreated()), Long.parseLong(headerDTO.getExpires()), req));
        if (crypt.verifySignature(hashedSigningString, headerDTO.getSignature(), GlobalConstants.ED_25519, Crypt.getPublicKey(GlobalConstants.ED_25519, Base64.getDecoder().decode(subs.getEncr_public_key())))) {
            LOGGER.info("{} |EUA/HSPA Header verification success", request.getContext().getMessageId());
            Mono<String> getData = processDiscoveryCall(request, subscriber);
            if (getData != null) return getData;
            if (GlobalConstants.ON_SEARCH.equalsIgnoreCase(request.getContext().getAction())) {
                result = Mono.just(gatewayUtil.generateAck());
            }
        } else {
           gatewayUtil.logErrorMessageForKibana(request,GatewayError.HEADER_VERFICATION_FAILED.getMessage(), GatewayError.HEADER_VERFICATION_FAILED.getCode());
           throw new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage());
        }
        return result;
    }

    private Mono<String> processDiscoveryCall(Request request, String subscriber) {
        if (GlobalConstants.SEARCH.equalsIgnoreCase(request.getContext().getAction())) {
            Mono<String> getData = circuitBreakerWrapper(request);
            return getData.flatMap(result1 -> {
                try {
                    return HSPAService.checklookupforHSPAs(result1, request);
                } catch (JsonProcessingException e) {
                    return Mono.error(new HeaderVerificationFailedError(e.getMessage()));
                }
            });
        }
        return null;
    }

    Mono<String> getParticipantsDetails(Context context, HeaderDTO params) throws JsonProcessingException {
        Subscriber subscriber = new Subscriber();
        Request request = new Request();
        request.setContext(context);
        Map<String, String> keyIdParams = crypt.extarctKeyId(params.getKeyId());
        String subscriber_id = keyIdParams.get(GlobalConstants.SUBSCRIBER_ID);
        subscriber.setSubscriber_id(subscriber_id);
        String pub_key_id = keyIdParams.get(GlobalConstants.PUB_KEY_ID);
        subscriber.setPub_key_id(pub_key_id);
        if (GlobalConstants.ON_SEARCH.equalsIgnoreCase(context.getAction())) {
            subscriber.setType(GlobalConstants.HSPA);
        } else {
            subscriber.setType(GlobalConstants.EUA);
        }
        subscriber.setCity(context.getCity());
        subscriber.setCountry(context.getCountry());
        subscriber.setStatus(GlobalConstants.SUBSCRIBED);
        subscriber.setDomain(context.getDomain());

        String payload = objectMapper.writeValueAsString(subscriber);
        LOGGER.info("{}  And payload is :: {}", context.getMessageId(), payload);
        return getWebClient.post().uri(registry_url_public.concat(GlobalConstants.INTERNAL)).body(BodyInserters.fromValue(payload)).retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new ParticipantValidationError(error))))
                .bodyToMono(String.class)
                .doOnSubscribe(
                        subscription -> LOGGER.info("{} | About to call Network Registry to find EUA details URL:{}",
                                context.getMessageId(), registry_url_public))
                .onErrorResume(err -> Mono.error(new GatewayException(err.getMessage())));
    }

    public Mono<String> circuitBreakerWrapper(Request body) {
        return circuitBreakerFactory.create("lookup").run(sendSignalToLookup(body), t -> {
            LOGGER.error("{} | Lookup called failed {}", body.getContext().getMessageId(), t);
            Request reqroot = new Request();
            return Mono.just(reqroot.toString());
        });
    }

    private Mono<String> sendSignalToLookup(Request body) {
        Subscriber subscriber = transformSubscriber(body);
        return getWebClient.post().uri(registry_url).body(BodyInserters.fromValue(subscriber)).retrieve()
                .bodyToMono(String.class)
                .doOnSubscribe(
                        subscription -> LOGGER.info("{} | About to call Network Registry to find list of HSPAs URL:{}",
                                body.getContext().getMessageId(), registry_url))
                .onErrorResume(error -> {
                    LOGGER.error("RequesterService::error::sendSingletoLookup::{}", error, error);
                    return Mono.error(new LookupException(GatewayError.LOOKUP_FAILED.getMessage()));
                });
    }

    private Subscriber transformSubscriber(Request request) {
        Subscriber subscriber = new Subscriber();
        Context context = request.getContext();
        subscriber.setCountry(context.getCountry());
        subscriber.setCity(context.getCity());
        subscriber.setDomain(context.getDomain());
        subscriber.setStatus(GlobalConstants.SUBSCRIBED);
        return subscriber;
    }
}
