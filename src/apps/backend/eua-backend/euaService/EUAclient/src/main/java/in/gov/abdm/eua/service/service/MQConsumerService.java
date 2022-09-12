package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.util.Map;

public interface MQConsumerService {

    Mono<AckResponseDTO> getAckResponseEntity(EuaRequestBody request, String bookignServiceUrl, Map<String, String> headersEncrypted);


    void prepareAndSendNackResponse(String nack, String messageId);

    @RabbitListener(queues = ConstantsUtils.QUEUE_EUA_TO_GATEWAY)
    void euaToGatewayConsumer(MqMessageTO request) throws IOException, JsonProcessingException;

    @RabbitListener(queues = ConstantsUtils.QUEUE_GATEWAY_TO_EUA)
    void gatewayToEuaConsumer(MqMessageTO response) throws JsonProcessingException;
}
