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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Value;
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


@Service
public class MQConsumerServiceImpl implements MQConsumerService {
    private static final Logger LOGGER = LoggerFactory.getLogger(MQConsumerServiceImpl.class);

    @Value("${spring.abdm_gateway_url}")
    private String abdmGatewayUrl;

    final
    ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;
    private final WebClient webClient;
    final
    SimpUserRegistry simpUserRegistry;


    public MQConsumerServiceImpl(ObjectMapper objectMapper, SimpMessagingTemplate template,
                                 WebClient webClient,
                                 SimpUserRegistry simpUserRegistry) {
        this.objectMapper = objectMapper;
        this.messagingTemplate = template;
        this.webClient = webClient;
        this.simpUserRegistry = simpUserRegistry;
    }

    @PostConstruct
    private void urlDisplay() {
        LOGGER.info(" POST CONSTRUCT abdmGatewayUrl is "+abdmGatewayUrl);
    }

    @Override
    public Mono<AckResponseDTO> getAckResponseResponseEntity(EuaRequestBody request, String bookignServiceUrl) {
        String url = null;

        url = getAppropriateUrl(request, bookignServiceUrl);
        url = url.concat("/"+request.getContext().getAction());
        LOGGER.info("URL in MQCOnsumerService is "+url);
        LOGGER.info("Context.Action is  "+request.getContext().getAction());
        LOGGER.info("Message ID is "+ request.getContext().getMessageId());

        Mono<AckResponseDTO> ackResponseMono = this.webClient.post().uri(url)
                .header("authorization","UHI")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(AckResponseDTO.class)
                .onErrorResume(errorFromGateway -> getErrorSchemaReady(errorFromGateway,errorFromGateway.getMessage()));

        String finalUrl = url;

        ackResponseMono.subscribe(res -> {
            LOGGER.info("Inside subscribe :: URL is :: "+ finalUrl);
            LOGGER.info("Response from webclient call is ====> "+res);
            Mono<AckResponseDTO> errorFromServerOtherThanStandard = getErrorFromServerIfNotStandard(res);
            handleErrorOtherThanStandard(request, errorFromServerOtherThanStandard);
            sendAckOrNack_ToWebClient(request.getContext().getMessageId(), res);
        });

        return ackResponseMono;
    }

    private String getAppropriateUrl(EuaRequestBody request, String bookignServiceUrl) {
        String url;
        if( null != request.getContext().getProviderUri()) {
            LOGGER.info("providerUrl :: "+ request.getContext().getProviderUri());
            url = request.getContext().getProviderUri();
        }else {
            LOGGER.info("GatewayUrl :: "+ abdmGatewayUrl);
            url = abdmGatewayUrl;
        }
        if(null != bookignServiceUrl) {
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
    public void euaToGatewayConsumer(MqMessageTO request) throws IOException, JsonProcessingException {
        LOGGER.info("Message read from MQ EUA_TO_GATEWAY::" + request);

        EuaRequestBody requestClass = objectMapper.readValue(request.getResponse(), EuaRequestBody.class);
        if("on_init".equals(requestClass.getContext().getAction()) && "on_confirm".equals(requestClass.getContext().getAction())) {
            getAckResponseResponseEntity(requestClass, ConstantsUtils.BOOKING_SERVICE_URL);
        }
        else{
            getAckResponseResponseEntity(requestClass, null);
        }

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

    private void handleErrorOtherThanStandard(EuaRequestBody request, Mono<AckResponseDTO> errorFromServerOtherThanStandard) {
        if(errorFromServerOtherThanStandard != null) {
            errorFromServerOtherThanStandard.subscribe(err -> {
                sendAckOrNack_ToWebClient(request.getContext().getMessageId(), err);
            });
        }
    }

    private void sendAckOrNack_ToWebClient(String messageId, AckResponseDTO err) {
        messagingTemplate.convertAndSendToUser(messageId, ConstantsUtils.QUEUE_SPECIFIC_USER, err);
    }

    private Mono<AckResponseDTO> getErrorFromServerIfNotStandard(AckResponseDTO res) {
        Mono<AckResponseDTO> errorFromServerOtherThanStandard;
        if(null != res.getError().getCode()) {
            errorFromServerOtherThanStandard = getErrorSchemaReady(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR), res.getError().getMessage());
            return errorFromServerOtherThanStandard;
        }
        return null;
    }

}
