package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
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

import java.lang.reflect.Field;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.sql.Timestamp;
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

    @Value("${spring.application.subscriberId_url}")
    String subscriberIdUrl;
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

    Mono<String> validateParticipant(Request request, Map<String, String> headers, String req, String subscriber, String requestId) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException, JsonProcessingException {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        Mono<String> result = null;
        List<Subscriber> subsList = appConfig.objectMapper().readValue(subscriber, new TypeReference<>() {
        });

        Subscriber subs = subsList.get(0);
        LOGGER.info("89 NetworkRegistryService validateParticipant() {} | Request ID: {} | Message ID: {} | EUA/HSPA validation success | trans ID: {} | getLocation :: {} ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getMessageId(), request.getContext().getTransactionId(),request.getMessage().getIntent()==null?"":request.getMessage().getIntent().getLocation());
        String action = request.getContext().getAction();
        String headerValue = headers.get(GlobalConstants.AUTHORIZATION);
        HeaderDTO headerDTO = objectMapper.readValue(headerValue, HeaderDTO.class);

        String hashedSigningString = crypt.generateBlakeHash(
                crypt.getSigningString(Long.parseLong(headerDTO.getCreated()), Long.parseLong(headerDTO.getExpires()), req));
        LOGGER.info("{} | Request ID: {} | Message ID: {} | Subscriber: {}",
                origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(),
                requestId, subs);
        if (crypt.verifySignature(hashedSigningString, headerDTO.getSignature(), GlobalConstants.ED_25519, Crypt.getPublicKey(GlobalConstants.ED_25519, Base64.getDecoder().decode(subs.getEncr_public_key())))) {
            LOGGER.info("{} | Request ID: {} | Message ID: {} | EUA/HSPA Header verification success, Processing DiscoveryCall", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getMessageId());
                Mono<String> getData = processDiscoveryCall(request, requestId);
                if (getData != null) return getData;
                if (GlobalConstants.SEARCH_AUDIT.equalsIgnoreCase(action)||GlobalConstants.ON_SEARCH.equalsIgnoreCase(action) ||
                        GlobalConstants.ON_CONFIRM_AUDIT.equalsIgnoreCase(action)|| GlobalConstants.ON_STATUS_AUDIT.equalsIgnoreCase(action) || GlobalConstants.ON_CANCEL_AUDIT.equalsIgnoreCase(action)) {
                    result = Mono.just(gatewayUtil.generateAck());

                }

        } else {
            LOGGER.info("Failed: {} | Request ID: {} | Message ID: {} |EUA/HSPA Header verification failed", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getMessageId());
            gatewayUtil.logErrorMessageForKibana(request,GatewayError.HEADER_VERFICATION_FAILED.getMessage(), GatewayError.HEADER_VERFICATION_FAILED.getCode());
            throw new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage());
        }
        return result;
    }


    private Mono<String> processDiscoveryCall(Request request, String requestId) {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        LOGGER.info("121 NetworkRegistryService processDiscoveryCall() {} | Request ID: {} | Message ID: {} | Processing Call : [ Action : {}, Consumer URI: {}, Provider URI: {} ]   | transaction id: {} | requestparam  {}",
                origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId,
                request.getContext().getMessageId(), request.getContext().getAction(), request.getContext().getConsumerUri(), request.getContext().getProviderUri(),request.getContext().getTransactionId(),request.getMessage().getIntent()==null?"":request.getMessage().getIntent().getLocation());
        if (GlobalConstants.SEARCH.equalsIgnoreCase(request.getContext().getAction())) {
            Mono<String> getData = circuitBreakerWrapper(request);
            return getData.flatMap(result1 -> {
                try {
                    LOGGER.info("{} | Request ID: {} | Message ID: {} | checklookupforHSPAs() with result: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, request.getContext().getMessageId(), result1);
                    return HSPAService.checklookupforHSPAs(result1, request, requestId);
                } catch (JsonProcessingException e) {
                    LOGGER.info("Error: {} | Request ID: {} | Message ID: {} | Exception: {}",
                            origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId,
                            request.getContext().getMessageId(), e.getMessage());
                    return Mono.error(new HeaderVerificationFailedError(e.getMessage()));
                }
            });
        }
        return null;
    }


    Mono<String> getParticipantsDetails(Context context, HeaderDTO params, String requestId,Request req) throws JsonProcessingException {
        Mono<String> consumer=isSubscriberIdExists(context.getConsumerId(),req);
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        return consumer.flatMap(cons->{
            try {
                List<Subscriber> consList = appConfig.objectMapper().readValue(cons, new TypeReference<>() {
                });
                if(!consList.isEmpty()) {
                    Subscriber subs = consList.get(0);
                    if(subs.getSubscriber_url().equals(context.getConsumerUri())) {
                        Subscriber subscriber = new Subscriber();
                        Request request = new Request();
                        request.setContext(context);
                        Map<String, String> keyIdParams = crypt.extarctKeyId(params.getKeyId());
                        String subscriber_id = keyIdParams.get(GlobalConstants.SUBSCRIBER_ID);
                        subscriber.setSubscriber_id(subscriber_id);
                        String pub_key_id = keyIdParams.get(GlobalConstants.PUB_KEY_ID);
                        subscriber.setPub_key_id(pub_key_id);
                        if (GlobalConstants.ON_SEARCH.equalsIgnoreCase(context.getAction()) || GlobalConstants.ON_CONFIRM_AUDIT.equalsIgnoreCase(context.getAction()) || GlobalConstants.ON_STATUS_AUDIT.equalsIgnoreCase(context.getAction()) || GlobalConstants.ON_CANCEL_AUDIT.equalsIgnoreCase(context.getAction())) {
                            subscriber.setType(GlobalConstants.HSPA);
                        } else {
                            subscriber.setType(GlobalConstants.EUA);
                        }
                        subscriber.setSubscriber_url(context.getConsumerUri());
                        subscriber.setCity(context.getCity());
                        subscriber.setCountry(context.getCountry());
                        subscriber.setStatus(GlobalConstants.SUBSCRIBED);
                        subscriber.setDomain(context.getDomain());

                        String payload = objectMapper.writeValueAsString(subscriber);
                        LOGGER.info("NETWORK REGISTRY SERVICE CALL {} | Request ID: {} | Message ID: {} and payload is :: {} | Transaction ID: {} | ", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, context.getMessageId(), payload, context.getTransactionId());
                        return getWebClient.post().uri(registry_url_public.concat(GlobalConstants.INTERNAL)).body(BodyInserters.fromValue(payload)).retrieve()
                                .onStatus(HttpStatus::is4xxClientError,
                                        response -> response.bodyToMono(String.class).flatMap(
                                                error ->
                                                {
                                                    LOGGER.error("170 getParticipantsDetails() 4xx Server Error Response: {} | target {}", error, registry_url_public + GlobalConstants.INTERNAL);
                                                    return Mono.error(new ParticipantValidationError(error));
                                                }
                                        )
                                )
                                .onStatus(HttpStatus::is5xxServerError,
                                        resp -> resp
                                                .bodyToMono(String.class).flatMap(error -> {
                                                    LOGGER.error("178 getParticipantsDetails() 5xx Server Error Response: {}| target {}", error, registry_url_public + GlobalConstants.INTERNAL);
                                                    return Mono.error(new ParticipantValidationError(error));
                                                }))
                                .bodyToMono(String.class)
                                .doOnSubscribe(
                                        subscription -> LOGGER.info("183 getParticipantsDetails() NETWORK REGISTRY SERVICE CALL {} | Request ID: {} | Message ID: {} | About to call Network Registry to find EUA details URL:{} | Transaction ID: {} | ",
                                                origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, context.getMessageId(), registry_url_public, context.getTransactionId()))
                                .onErrorResume(err -> {
                                    LOGGER.info("NETWORK REGISTRY response getParticipantsDetails() onErrorResume() stack trash {} transaction id {}", err.getStackTrace(), context.getTransactionId());
                                    return Mono.error(new GatewayException(err.getMessage()));
                                });
                    }
                    return gatewayUtil.generateNack(GatewayError.EUA_SUBSCRIBER_URL_NOT_FOUND.getMessage(),
                            GatewayError.EUA_SUBSCRIBER_URL_NOT_FOUND.getCode(), req);
                }
                return gatewayUtil.generateNack(GatewayError.EUA_SUBSCRIBER_ID_NOT_FOUND.getMessage(),
                        GatewayError.EUA_SUBSCRIBER_ID_NOT_FOUND.getCode(), req);

            } catch (JsonProcessingException e) {
                throw new RuntimeException(e);
            }
        });

    }
Mono<String> getParticipantsDetailsForOnSearch(Context context, HeaderDTO params, String requestId,Request req) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException  {
    Mono<String> consumer=isSubscriberIdExists(context.getConsumerId(),req);
    StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
    String origin = trace.getClassName()+"."+trace.getMethodName();
    Mono<String> provider=isSubscriberIdExists(context.getProviderId(),req);
    return consumer.flatMap(cons-> provider.flatMap(prov->{
        try{
            List<Subscriber> subsList = appConfig.objectMapper().readValue(cons, new TypeReference<>() {
            });
            List<Subscriber> provList = appConfig.objectMapper().readValue(prov, new TypeReference<>() {
            });
             if (!subsList.isEmpty()) {
                 if(!provList.isEmpty()){
                     Subscriber consumerSub = subsList.get(0);
                     Subscriber providerSub=provList.get(0);
                     if (consumerSub.getSubscriber_url().equals(req.getContext().getConsumerUri())) {
                         if(providerSub.getSubscriber_url().equals(req.getContext().getProviderUri())) {
                             Subscriber subscriber = new Subscriber();
                             Request request = new Request();
                             request.setContext(context);
                             Map<String, String> keyIdParams = crypt.extarctKeyId(params.getKeyId());
                             String subscriber_id = keyIdParams.get(GlobalConstants.SUBSCRIBER_ID);
                             subscriber.setSubscriber_id(subscriber_id);
                             String pub_key_id = keyIdParams.get(GlobalConstants.PUB_KEY_ID);
                             subscriber.setPub_key_id(pub_key_id);
                             if (GlobalConstants.ON_SEARCH.equalsIgnoreCase(context.getAction()) || GlobalConstants.ON_CONFIRM_AUDIT.equalsIgnoreCase(context.getAction()) || GlobalConstants.ON_STATUS_AUDIT.equalsIgnoreCase(context.getAction()) || GlobalConstants.ON_CANCEL_AUDIT.equalsIgnoreCase(context.getAction())) {
                                 subscriber.setType(GlobalConstants.HSPA);
                             } else {
                                 subscriber.setType(GlobalConstants.EUA);
                             }

                             subscriber.setSubscriber_url(context.getProviderUri());
                             subscriber.setCity(context.getCity());
                             subscriber.setCountry(context.getCountry());
                             subscriber.setStatus(GlobalConstants.SUBSCRIBED);
                             subscriber.setDomain(context.getDomain());
                             String payload = objectMapper.writeValueAsString(subscriber);
                             LOGGER.info("NETWORK REGISTRY SERVICE CALL {} | Request ID: {} | Message ID: {} and payload is :: {} | Transaction ID: {} | ", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, context.getMessageId(), payload, context.getTransactionId());
                             return getWebClient.post().uri(registry_url_public.concat(GlobalConstants.INTERNAL)).body(BodyInserters.fromValue(payload)).retrieve()
                                     .onStatus(HttpStatus::is4xxClientError,
                                             response -> response.bodyToMono(String.class).flatMap(
                                                     error ->
                                                     {
                                                         LOGGER.error("170 getParticipantsDetails() 4xx Server Error Response: {} | target {}", error, registry_url_public + GlobalConstants.INTERNAL);
                                                         return Mono.error(new ParticipantValidationError(error));
                                                     }
                                                     )
                                     )
                                     .onStatus(HttpStatus::is5xxServerError,
                                             resp -> resp
                                                     .bodyToMono(String.class).flatMap(error -> {
                                                         LOGGER.error("178 getParticipantsDetails() 5xx Server Error Response: {}| target {}", error, registry_url_public + GlobalConstants.INTERNAL);
                                                         return Mono.error(new ParticipantValidationError(error));
                                                     }))
                                     .bodyToMono(String.class)
                                     .doOnSubscribe(
                                             subscription -> LOGGER.info("183 getParticipantsDetails() NETWORK REGISTRY SERVICE CALL {} | Request ID: {} | Message ID: {} | About to call Network Registry to find EUA details URL:{} | Transaction ID: {} | ",
                                          origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, context.getMessageId(), registry_url_public, context.getTransactionId()))
                                     .onErrorResume(err -> {
                                         LOGGER.info("NETWORK REGISTRY response getParticipantsDetails() onErrorResume() stack trash {} transaction id {}", err.getStackTrace(), context.getTransactionId());
                                         return Mono.error(new GatewayException(err.getMessage()));
                                     });
                         }
                         return gatewayUtil.generateNack(GatewayError.HSPA_SUBSCRIBER_URL_NOT_FOUND.getMessage(),
                                 GatewayError.HSPA_SUBSCRIBER_URL_NOT_FOUND.getCode(), req);
                     }
                     return gatewayUtil.generateNack(GatewayError.EUA_SUBSCRIBER_URL_NOT_FOUND.getMessage(),
                             GatewayError.EUA_SUBSCRIBER_URL_NOT_FOUND.getCode(), req);
                 }
                 return gatewayUtil.generateNack(GatewayError.HSPA_SUBSCRIBER_ID_NOT_FOUND.getMessage(),
                         GatewayError.HSPA_SUBSCRIBER_ID_NOT_FOUND.getCode(), req);
             }
             return gatewayUtil.generateNack(GatewayError.EUA_SUBSCRIBER_ID_NOT_FOUND.getMessage(),
                     GatewayError.EUA_SUBSCRIBER_ID_NOT_FOUND.getCode(), req);

        }
        catch (JsonProcessingException e) {
            LOGGER.info("SEARCH ENDPOINT search() processor()  Error: {} | Request ID: {} | Request {} | Exception: {} | Code: {} | Transaction ID: {} | ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId,e.getMessage(), GatewayError.INVALID_KEY.getCode(), context.getTransactionId());
            return Mono.error(new GatewayException(e.getMessage()));
        }
    }));

}


    Mono<String> isSubscriberIdExists(String subscriberId,Request request){
        Mono<String> response = null;
        response=getWebClient.get().uri(subscriberIdUrl.concat(subscriberId)).retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        resp -> resp.bodyToMono(String.class)
                                .flatMap(error -> Mono.error(new GatewayException(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        resp -> resp
                                .bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
                .bodyToMono(String.class)
                .onErrorResume(error -> gatewayUtil.generateNack("Subscriber does not exist",
                        GatewayError.HSPA_FAILED.getCode(),request )).log();

        return response;

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
