package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.uhi.common.dto.Request;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;

public interface MQConsumerService {

    Mono<String> webclientCallToPartnerOrGateway(Request request, String bookingServiceUrl, String requestString, String dhpQueryType) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException;
    void pushToMqGatewayTOEua(MqMessageTO message, String requestMessageId);

    void pushToMq(String searchRequest, String clientId, String action, String requestMessageId);
    void prepareAndSendNackResponse(String nack, String messageId) throws JsonProcessingException;

    MqMessageTO extractMessage(String searchRequest, String consumerId, String requestMessageId, String action);

    void processResponse(String onSearchRequestString, Request responseClass, String headerName, Map<String,String> httpRequestHeaders, MqMessageTO message) throws JsonProcessingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException, SignatureException, InvalidKeySpecException;

    @RabbitListener(queues = ConstantsUtils.QUEUE_EUA_TO_GATEWAY)
    void euaToGatewayConsumer(MqMessageTO request) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException;

    @RabbitListener(queues = ConstantsUtils.QUEUE_GATEWAY_TO_EUA)
    void gatewayToEuaConsumer(MqMessageTO response) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException;
}
