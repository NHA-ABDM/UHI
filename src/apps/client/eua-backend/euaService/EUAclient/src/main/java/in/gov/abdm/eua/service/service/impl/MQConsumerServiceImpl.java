package in.gov.abdm.eua.service.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.constants.GlobalConstants;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.eua.service.exceptions.EuaException;
import in.gov.abdm.eua.service.service.MQConsumerService;
import in.gov.abdm.eua.service.utils.Crypt;
import in.gov.abdm.eua.service.utils.EuaUtility;
import in.gov.abdm.uhi.common.dto.HeaderDTO;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Subscriber;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.user.SimpUserRegistry;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;


@Service
public class MQConsumerServiceImpl implements MQConsumerService {
    private static final Logger LOGGER = LoggerFactory.getLogger(MQConsumerServiceImpl.class);
    final
    ObjectMapper objectMapper;
    final
    SimpUserRegistry simpUserRegistry;
    final Crypt cryptService;
    private final SimpMessagingTemplate messagingTemplate;
    private final WebClient webClient;
    @Value("${spring.abdm_gateway_url}")
    private String abdmGatewayUrl;
    @Value("${spring.header.encrypt.publicKeyId}")
    private String headerPublicKeyId;

    @Value("${spring.header.encrypt.bloodbank.publicKeyId}")
    private String headerBloodBankPublicKeyId;
    @Value("${spring.header.encrypt.privateKey}")
    private String headerPrivateKey;
//    @Value("${spring.header.encrypt.subscriberId}")
//    private String subscriberId;
    @Value("${spring.header.encrypt.publicKey}")
    private String publicKey;
    @Value("${spring.abdm_bookingService_url}")
    private String bookingServiceUrl;
    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    @Value("${spring.header.encrypt.gatewayPublicKey}")
    private String gatewayPublicKey;

    @Value("${spring.header.encrypt.subscriberCity}")
    private String subscriberCity;

    @Value("${spring.header.encrypt.domain}")
    private String subscriberDomain;

    @Value("${spring.header.encrypt.bloodbank.domain}")
    private String subscriberBloodBankDomain;

    @Value("${spring.header.encrypt.country}")
    private String subscriberCountry;

    @Value("${spring.application.registry_url_public}")
    private String registryUrl;

    final
    EuaUtility euaUtility;

    private final RabbitTemplate template;

    public MQConsumerServiceImpl(ObjectMapper objectMapper, SimpMessagingTemplate template,
                                 WebClient webClient,
                                 SimpUserRegistry simpUserRegistry, Crypt cryptService, EuaUtility euaUtility, RabbitTemplate template1) {
        this.objectMapper = objectMapper;
        this.messagingTemplate = template;
        this.webClient = webClient;
        this.simpUserRegistry = simpUserRegistry;
        this.cryptService = cryptService;
        this.euaUtility = euaUtility;
        this.template = template1;
    }

    @PostConstruct
    private void urlDisplay() {
        LOGGER.info(" POST CONSTRUCT abdmGatewayUrl is {}", abdmGatewayUrl);
    }

    @Override
    public Mono<String> webclientCallToPartnerOrGateway(Request request, String bookingServiceUrl, String requestString, String dhpQueryType) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {
        String url;
        url = getAppropriateUrl(request, bookingServiceUrl);
        url = url.concat("/" + dhpQueryType);
        LOGGER.info("URL in MQCOnsumerService is {} ", url);
        LOGGER.info("Context.Action is {}", request.getContext().getAction());
        LOGGER.info("Message ID is {}", request.getContext().getMessageId());
        String publickeyId = headerPublicKeyId;
        String domain = request.getContext().getDomain();
        String subscriberId = request.getContext().getConsumerId();
        if(domain.equalsIgnoreCase(subscriberBloodBankDomain))
        {
            subscriberId = "nha.eua";
            publickeyId = headerBloodBankPublicKeyId;
        }
        String headersEncrypted = generateUhiAuthorizationHeader(requestString, publickeyId, subscriberId);

        Mono<String> ackResponseMono;
        if (Boolean.parseBoolean(isHeaderEnabled)) {
            LOGGER.info(" {} | Header is ->>>>>>>> {}", request.getContext().getMessageId(), headersEncrypted);
        }

            ackResponseMono = this.webClient.post().uri(url)
                    .header(GlobalConstants.AUTHORIZATION, headersEncrypted)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(requestString))
                    .retrieve()
                    .onStatus(HttpStatus::is4xxClientError,
                            response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new EuaException(error))))
                    .onStatus(HttpStatus::is5xxServerError,
                            response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new EuaException(error))))
                    .bodyToMono(String.class)
                    .onErrorResume(err -> {
                        try {
                            return Mono.just(getErrorSchemaReady(err));
                        } catch (JsonProcessingException e) {
                           return Mono.error(new EuaException(e.getMessage()));
                        }
                    });

            String finalUrl = url;

        Request finalRequest = request;
        ackResponseMono = ackResponseMono.doOnNext(res -> {
                LOGGER.info("Inside subscribe :: URL is :: {}", finalUrl);
                LOGGER.info("Response from webclient call is ====> {}", res);
                sendAckOrNackToWebClient(finalRequest.getContext().getMessageId(), res);
            });

        return ackResponseMono;
    }


    private String getAppropriateUrl(Request request, String bookignServiceUrl) {
        String url;
        boolean isProviderNotNull = null != request.getContext().getProviderUri();
        boolean isBookingServiceUrlPresent = null != bookignServiceUrl;

        if (isProviderNotNull) {
            LOGGER.info("providerUrl :: {}", request.getContext().getProviderUri());
            url = request.getContext().getProviderUri();
        } else {
            LOGGER.info("GatewayUrl :: {}", abdmGatewayUrl);
            url = abdmGatewayUrl;
        }

        if (isBookingServiceUrlPresent) {
            LOGGER.info("BookingServiceUrl :: {}", bookignServiceUrl);
            url = bookignServiceUrl;
        }
        return url;
    }

    @Override
    public void prepareAndSendNackResponse(String nack, String messageId) throws JsonProcessingException {
        LOGGER.info("Exception occurred. Message ID is {}{}", messageId, " Sending NACK response");

        String error = getErrorSchemaReady(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR));
        sendAckOrNackToWebClient(messageId, error);
    }

    @Override
    @RabbitListener(queues = ConstantsUtils.QUEUE_EUA_TO_GATEWAY)
    public void euaToGatewayConsumer(MqMessageTO request) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        LOGGER.info("Message read from MQ EUA_TO_GATEWAY::{}", request.getResponse());

        Request requestClass = objectMapper.readValue(request.getResponse(), Request.class);
        String requestString = request.getResponse();

        if (ConstantsUtils.ON_INIT_ENDPOINT.equals(requestClass.getContext().getAction())
                || ConstantsUtils.ON_CONFIRM_ENDPOINT.equals(requestClass.getContext().getAction())
                || ConstantsUtils.MESSAGE_ENDPOINT.equals(requestClass.getContext().getAction())
                || ConstantsUtils.ON_MESSAGE_ENDPOINT.equals(requestClass.getContext().getAction())) {
            webclientCallToPartnerOrGateway(requestClass, bookingServiceUrl, requestString, request.getDhpQueryType()).subscribe();
        } else {
            webclientCallToPartnerOrGateway(requestClass, null, requestString, request.getDhpQueryType()).subscribe();
        }
    }

//    private String generateUhiAuthorizationHeader(String requestString) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeySpecException, JsonProcessingException {
//        PrivateKey privateKey = Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(headerPrivateKey));
//        String headersEncrypted = new Crypt("BC").generateAuthorizationParams(subscriberId, headerPublicKeyId, requestString, privateKey);
//        return headersEncrypted;
//    }

    private String generateUhiAuthorizationHeader(String requestString, String publicKeyId, String subscriberId) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeySpecException, JsonProcessingException {
        PrivateKey privateKey = Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(headerPrivateKey));
        String headersEncrypted = new Crypt("BC").generateAuthorizationParams(subscriberId, publicKeyId, requestString, privateKey);
        return headersEncrypted;
    }

    @Override
    @RabbitListener(queues = ConstantsUtils.QUEUE_GATEWAY_TO_EUA)
    public void gatewayToEuaConsumer(MqMessageTO response) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException {
        Request responseClass = objectMapper.readValue(response.getResponse(), Request.class);
        messagingTemplate.convertAndSendToUser(responseClass.getContext().getMessageId(), "/queue/specific-user", response);
    }


    @Override
    public void pushToMqGatewayTOEua(MqMessageTO message, String requestMessageId) {
        LOGGER.info("Pushing to MQ. Message ID is {}", requestMessageId);
        LOGGER.info("Inside GATEWAY_TO_EUA queue convertAndSend... Queue name is =====> " + ConstantsUtils.ROUTING_KEY_GATEWAY_TO_EUA);
        List<Request> dataToSend = new ArrayList<>();
        try {
            if(message.getDhpQueryType().equalsIgnoreCase("on_search")) {
                dataToSend = euaUtility.splitJsonFile(message.getResponse());
                for (Request request : dataToSend) {
                    MqMessageTO mqMessageTO = extractMessage(objectMapper.writeValueAsString(request), message.getConsumerId(), message.getMessageId(), message.getDhpQueryType());
                    template.convertAndSend(ConstantsUtils.EXCHANGE, ConstantsUtils.ROUTING_KEY_GATEWAY_TO_EUA, mqMessageTO);
                }
            }
            else{
                template.convertAndSend(ConstantsUtils.EXCHANGE, ConstantsUtils.ROUTING_KEY_GATEWAY_TO_EUA, message);

            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void pushToMq(String searchRequest, String clientId, String action, String requestMessageId) {
        LOGGER.info("pushToMq {} ---- {} ---- {} ---- {}", searchRequest, clientId, action, requestMessageId);
        LOGGER.info("Pushing to MQ. Message ID is {}", requestMessageId);
        MqMessageTO message = extractMessage(searchRequest, clientId, requestMessageId, action);
        template.convertAndSend(ConstantsUtils.EXCHANGE, ConstantsUtils.ROUTING_KEY_EUA_TO_GATEWAY, message);
    }

    @Override
    public MqMessageTO extractMessage(String searchRequest, String consumerId, String requestMessageId, String action) {
        MqMessageTO message = new MqMessageTO();
        message.setMessageId(requestMessageId);
        message.setConsumerId(consumerId);
        message.setCreatedAt(LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS).toString());
        message.setResponse(searchRequest);
        message.setDhpQueryType(action);
        return message;
    }

    @Override
    public void processResponse(String response, Request responseClass, String headerName, Map<String,String> httpRequestHeaders, MqMessageTO message) throws JsonProcessingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException, SignatureException, InvalidKeySpecException {
        if (Boolean.parseBoolean(isHeaderEnabled)) {


            if(GlobalConstants.X_GATEWAY_AUTHORIZATION.equalsIgnoreCase(headerName)) {
                verifyHeaders(response,responseClass, httpRequestHeaders, headerName, gatewayPublicKey);
                pushToMqGatewayTOEua(message, responseClass.getContext().getMessageId());
            }
            else if(GlobalConstants.AUTHORIZATION.equalsIgnoreCase(headerName)) {

                String publickeyId = headerPublicKeyId;
                String domain = responseClass.getContext().getDomain();
                String subscriberId = responseClass.getContext().getConsumerId();
                if(domain.equalsIgnoreCase(subscriberBloodBankDomain))
                {
                    publickeyId = headerBloodBankPublicKeyId;
                }

                HeaderDTO hspaHeaderDto = cryptService.extractAuthorizationParams(headerName, httpRequestHeaders, responseClass);
                Map<String, String> hspaKeyId = cryptService.extarctKeyId(hspaHeaderDto.getKeyId());
                Subscriber subscriber = Subscriber.builder().subscriber_id(hspaKeyId.get("subscriber_id")).type(GlobalConstants.HSPA).city(responseClass.getContext().getCity()).pub_key_id(hspaKeyId.get("pub_key_id")).domain(responseClass.getContext().getDomain()).country(responseClass.getContext().getCountry()).subscriber_url(responseClass.getContext().getProviderUri()).build();
                LOGGER.info("{} | {}::GatewayUtility:: EUA Subscriber generated for lookup:: {}", responseClass.getContext().getMessageId(), this.getClass().getName(), objectMapper.writeValueAsString(subscriber));
                String authHeader = cryptService.generateAuthorizationParams(subscriberId, publickeyId, objectMapper.writeValueAsString(subscriber), Crypt.getPrivateKey("Ed25519", Base64.getDecoder().decode(headerPrivateKey)));
                LOGGER.info("{} | {}::GatewayUtility:: header generated for lookup:: {}", responseClass.getContext().getMessageId(), this.getClass().getName(), authHeader);
                Mono<List<Subscriber>> lookupResponse = processLookupCall(responseClass, subscriber, authHeader);

                lookupResponse.flatMap(lookupRes-> {
                    if(!lookupRes.isEmpty()) {
                        try {
                            if (verifyHeaders(response,responseClass, httpRequestHeaders, headerName, lookupRes.get(0).getEncr_public_key())) {
                                pushToMqGatewayTOEua(message, responseClass.getContext().getMessageId());
                            }
                        } catch (JsonProcessingException | NoSuchAlgorithmException | NoSuchProviderException |
                                 InvalidKeyException | SignatureException | InvalidKeySpecException e) {
                            LOGGER.error("{} | {}::gatewayToEuaConsumer::error::{}", responseClass.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                        }
                    }
                    return Mono.empty();
                }).subscribe();
            }
        }
        else {
            pushToMqGatewayTOEua(message, responseClass.getContext().getMessageId());
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
                    return Mono.error(new EuaException(error.getLocalizedMessage()));
                });
    }

    public boolean verifyHeaders(String response, Request responseClass,Map<String, String> httpRequestHeaders, String headerName, String publicKey) throws JsonProcessingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException, SignatureException, InvalidKeySpecException {
        String headersString;
        headersString = httpRequestHeaders.get(headerName);
        LOGGER.info("{}|Header is ->>>>>>>> {}", responseClass.getContext().getMessageId(),headersString);
        HeaderDTO headerParams = cryptService.extractAuthorizationParams(headerName, httpRequestHeaders, responseClass);
        String hashedSigningString = cryptService.generateBlakeHash(
            cryptService.getSigningString(Long.parseLong(headerParams.getCreated()), Long.parseLong(headerParams.getExpires()), response));
        if (cryptService.verifySignature(hashedSigningString, headerParams.getSignature(), GlobalConstants.ED_25519, Crypt.getPublicKey(GlobalConstants.ED_25519, Base64.getDecoder().decode(publicKey)))) {
            LOGGER.info("{} | {}::gatewayToEuaConsumer::Header verification successful", responseClass.getContext().getMessageId(),this.getClass().getName());
            return true;
        }
        else {
            LOGGER.error("{} | {}::gatewayToEuaConsumer::Header verification failed", responseClass.getContext().getMessageId(),this.getClass().getName());
            return false;
        }
    }

    private String getErrorSchemaReady(Throwable error) throws JsonProcessingException {
        LOGGER.error("MQConsumerService::error::onErrorResume::{}", error.getMessage());
        return euaUtility.generateNackWithoutKibana(error.getLocalizedMessage(), "500");
    }


    private void sendAckOrNackToWebClient(String messageId, String err) {
        LOGGER.info("{} | sendAckOrNackToWebClient || error {}", messageId, err);
        messagingTemplate.convertAndSendToUser(messageId, ConstantsUtils.QUEUE_SPECIFIC_USER, err);
    }
}
