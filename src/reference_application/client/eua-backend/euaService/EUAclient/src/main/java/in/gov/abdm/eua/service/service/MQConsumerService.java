package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.messaging.handler.annotation.Header;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.nio.channels.Channel;

public interface MQConsumerService {

    Mono<AckResponseDTO> getAckResponseResponseEntity(EuaRequestBody request, String bookignServiceUrl);

    void prepareAndSendNackResponse(String nack, String messageId);

    @RabbitListener(queues = ConstantsUtils.QUEUE_EUA_TO_GATEWAY)
    void euaToGatewayConsumer(MqMessageTO request) throws IOException, JsonProcessingException;

    @RabbitListener(queues = ConstantsUtils.QUEUE_GATEWAY_TO_EUA)
    void gatewayToEuaConsumer(MqMessageTO response) throws JsonProcessingException;
}
