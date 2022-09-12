package in.gov.abdm.eua.service.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;

import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.eua.service.exceptions.PhrException400;
import in.gov.abdm.eua.service.exceptions.PhrException500;
import in.gov.abdm.eua.service.service.MQConsumerService;
import in.gov.abdm.uhi.common.dto.Error;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.user.SimpUserRegistry;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import javax.annotation.PostConstruct;
import java.io.IOException;
import java.security.PrivateKey;
import java.util.*;
import java.util.function.Consumer;


@Service
public class MQConsumerServiceImpl implements MQConsumerService {
    private static final Logger LOGGER = LoggerFactory.getLogger(MQConsumerServiceImpl.class);

    @Value("${spring.abdm_gateway_url}")
    private String abdmGatewayUrl;

    @Value("${spring.header.encrypt.publicKeyId}")
    private String headerPublicKeyId;

    @Value("${spring.header.encrypt.privateKey}")
    private String headerPrivateKey;

    @Value("${spring.header.encrypt.subscriberId}")
    private String subscriberId;



    final
    ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;
    private final WebClient webClient;
    final
    SimpUserRegistry simpUserRegistry;
    final Crypt cryptService;


    public MQConsumerServiceImpl(ObjectMapper objectMapper, SimpMessagingTemplate template,
                                 WebClient webClient,
                                 SimpUserRegistry simpUserRegistry, Crypt cryptService) {
        this.objectMapper = objectMapper;
        this.messagingTemplate = template;
        this.webClient = webClient;
        this.simpUserRegistry = simpUserRegistry;
        this.cryptService = cryptService;
    }

    @PostConstruct
    private void urlDisplay() {
        LOGGER.info(" POST CONSTRUCT abdmGatewayUrl is "+abdmGatewayUrl);
    }

    @Override
    public Mono<AckResponseDTO> getAckResponseEntity(EuaRequestBody request, String bookignServiceUrl, Map<String, String> headersEncrypted) {
        String url = null;

        url = getAppropriateUrl(request, bookignServiceUrl);
        url = url.concat("/"+request.getContext().getAction());
        LOGGER.info("URL in MQCOnsumerService is "+url);
        LOGGER.info("Context.Action is  "+request.getContext().getAction());
        LOGGER.info("Message ID is "+ request.getContext().getMessageId());

        HttpHeaders headers = new HttpHeaders();
        if(headersEncrypted != null) {
            String headersString = removeCurlyBracesAndHeaderEqualsSigns(headersEncrypted);
            headers.add("Authorization", headersString);
            LOGGER.info("Headers are ->>>>>>>>"+ headersString);
        }

        Consumer<HttpHeaders> consumer = it -> it.addAll(headers);


        Mono<AckResponseDTO> ackResponseMono = this.webClient.post().uri(url)
//                .header("authorization","uhi")
                .headers(consumer)
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(AckResponseDTO.class)
                .onErrorResume(errorFromGateway -> getErrorSchemaReady(errorFromGateway,errorFromGateway.getMessage()));

        String finalUrl = url;

        ackResponseMono.doOnNext(res -> {
            LOGGER.info("Inside subscribe :: URL is :: "+ finalUrl);
            LOGGER.info("Response from webclient call is ====> "+res);
            sendAckOrNack_ToWebClient(request.getContext().getMessageId(), res);
        });

        return ackResponseMono;
    }

    private String removeCurlyBracesAndHeaderEqualsSigns(Map<String, String> headersEncrypted) {
        String headersString = String.valueOf(headersEncrypted);
        headersString = headersString.replaceAll("\\}","");
        headersString = headersString.replaceAll("\\{", "");
        return headersString;
    }

    private String getAppropriateUrl(EuaRequestBody request, String bookignServiceUrl) {
        String url;
        boolean isProviderNotNull = null != request.getContext().getProviderUri();
        boolean isBookingServiceUrlPresent = null != bookignServiceUrl;

        if(isProviderNotNull) {
            LOGGER.info("providerUrl :: "+ request.getContext().getProviderUri());
            url = request.getContext().getProviderUri();
        }else {
            LOGGER.info("GatewayUrl :: "+ abdmGatewayUrl);
            url = abdmGatewayUrl;
        }

        if(isBookingServiceUrlPresent) {
            LOGGER.info("BookingServiceUrl :: "+ bookignServiceUrl);
                url = bookignServiceUrl;
        }
        return url;
    }

    @Override
    public void prepareAndSendNackResponse(String nack, String messageId) {
        LOGGER.info("Exception occurred. Message ID is "+ messageId+" Sending NACK response");

        Mono<AckResponseDTO> error = getErrorSchemaReady(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR), nack);
        error.subscribe(err -> {
            sendAckOrNack_ToWebClient(messageId,err);
        });
    }


    @Override
    @RabbitListener(queues = ConstantsUtils.QUEUE_EUA_TO_GATEWAY)
    public void euaToGatewayConsumer(MqMessageTO request) throws IOException {
        LOGGER.info("Message read from MQ EUA_TO_GATEWAY::" + request.getResponse());

        EuaRequestBody requestClass = objectMapper.readValue(request.getResponse(), EuaRequestBody.class);
        PrivateKey privateKey = cryptService.getPrivateKey(EdDSAParameterSpec.Ed25519, headerPrivateKey);
        Map<String, String> headersEncrypted = new Crypt("BC").generateAuthorizationParams(subscriberId, headerPublicKeyId, request.getResponse(), privateKey);

        verifyParams(request, headersEncrypted);


        if(ConstantsUtils.ON_INIT_ENDPOINT.equals(requestClass.getContext().getAction()) && ConstantsUtils.ON_CONFIRM_ENDPOINT.equals(requestClass.getContext().getAction())) {
            getAckResponseEntity(requestClass, ConstantsUtils.BOOKING_SERVICE_URL, headersEncrypted).subscribe();

        }
        else{
            getAckResponseEntity(requestClass, null, headersEncrypted).subscribe();
        }
    }

    private void verifyParams(MqMessageTO request, Map<String, String> headersEncrypted) throws JsonProcessingException {
        String publicKey = "MCowBQYDK2VwAyEAQCWv0rw/WPtm3xLcXChk0/Px8yNK9l2AcyoQWXbHsD8=";


        String payload = request.getResponse();
        long created = Long.parseLong(headersEncrypted.get("created"));
        long expires = Long.parseLong(headersEncrypted.get("expires"));
        String hashedSigningString = cryptService.generateBlakeHash(cryptService.getSigningString(created, expires, payload));

        String signature = headersEncrypted.get("signature");
        LOGGER.info("Verfication result|" + cryptService.verifySignature1(signature, hashedSigningString, publicKey));
    }

    @Override
    @RabbitListener(queues = ConstantsUtils.QUEUE_GATEWAY_TO_EUA)
    public void gatewayToEuaConsumer(MqMessageTO response) throws JsonProcessingException {
        LOGGER.info("Message read from MQ GATEWAY_TO_EUA::" + response);

        EuaRequestBody responseClass = objectMapper.readValue(response.getResponse(), EuaRequestBody.class);

        messagingTemplate.convertAndSendToUser(responseClass.getContext().getMessageId(),"/queue/specific-user", response);
    }

    private Mono<AckResponseDTO> getErrorSchemaReady(Throwable error, String errorMessage)  {
        LOGGER.error("MQConsumerService::error::onErrorResume::" + error.getMessage());

        AckResponseDTO ackResponseErr = null;
        try {
            ackResponseErr = prepareErrorObjectAck();
        } catch (JsonProcessingException e) {
           LOGGER.error(e.getMessage());
        }
        Mono<AckResponseDTO> errorMono = null;
        if (ackResponseErr != null) {
            errorMono = Mono.just(ackResponseErr);

            errorMono.subscribe(err -> {
                LOGGER.error(error.getLocalizedMessage());
                err.getError().setMessage(error.getLocalizedMessage());
                err.getError().setCode("500");
                err.getError().setPath("MQConsumerService");
            });
        }
            return errorMono;
    }

    private AckResponseDTO prepareErrorObjectAck() throws JsonProcessingException {
        return objectMapper.readValue(ConstantsUtils.NACK_RESPONSE, AckResponseDTO.class);
    }


    private void sendAckOrNack_ToWebClient(String messageId, AckResponseDTO err) {
    	LOGGER.info("sendAckOrNack_ToWebClient "+messageId+"     "+err);
        messagingTemplate.convertAndSendToUser(messageId, ConstantsUtils.QUEUE_SPECIFIC_USER, err);
    }

}
