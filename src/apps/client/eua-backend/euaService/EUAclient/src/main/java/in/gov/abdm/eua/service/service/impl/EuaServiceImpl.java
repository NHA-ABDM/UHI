package in.gov.abdm.eua.service.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.eua.service.service.EuaService;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Service
@Slf4j
public class EuaServiceImpl implements EuaService {
    private static final Logger LOGGER = LoggerFactory.getLogger(EuaServiceImpl.class);
    private final RabbitTemplate template;
    private final ObjectMapper objectMapper;
    private final ModelMapper modelMapper;
    private final String NACK_RESPONSE = "{ \"message\": { \"ack\": { \"status\": \"NACK\" } }, \"error\": { \"type\": \"\", \"code\": \"500\", \"path\": \"string\", \"message\": \"Something went wrong\" } }";

    public EuaServiceImpl(RabbitTemplate template, ObjectMapper objectMapper, ModelMapper modelMapper) {
        this.template = template;
        this.objectMapper = objectMapper;
        this.modelMapper = modelMapper;
    }

    @Override
    public void pushToMqGatewayTOEua(MqMessageTO message, String requestMessageId) {
        LOGGER.info("Pushing to MQ. Message ID is "+ requestMessageId);
        LOGGER.info("Inside GATEWAY_TO_EUA queue convertAndSend... Queue name is =====> "+ConstantsUtils.ROUTING_KEY_GATEWAY_TO_EUA);
        template.convertAndSend(ConstantsUtils.EXCHANGE, ConstantsUtils.ROUTING_KEY_GATEWAY_TO_EUA, message);


    }

    @Override
    public void pushToMq(String searchRequest, String clientId, String action, String requestMessageId) {
        LOGGER.info("Pushing to MQ. Message ID is "+ requestMessageId);
        MqMessageTO message = extractMessage(searchRequest,clientId, requestMessageId, action);
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
    public ResponseEntity<AckResponseDTO> getOnAckResponseResponseEntity(ObjectMapper objectMapper, String onRequest, String dhpQueryType, String requestMessageId) throws com.fasterxml.jackson.core.JsonProcessingException {
        if (onRequest == null) {
            LOGGER.error("ERROR. Request is null"+ requestMessageId);
            LOGGER.error("Error with response. Response is "+onRequest);
            AckResponseDTO onSearchAck = objectMapper.readValue(NACK_RESPONSE, AckResponseDTO.class);
            return new ResponseEntity<>(onSearchAck, HttpStatus.INTERNAL_SERVER_ERROR);

        } else {
            LOGGER.info("Success... Message ID is"+ requestMessageId);
            String onRequestAckJsonString = "{ \"message\": { \"ack\": { \"status\": \"ACK\" } } }";
            AckResponseDTO onSearchAck = objectMapper.readValue(onRequestAckJsonString, AckResponseDTO.class);
            return new ResponseEntity<>(onSearchAck, HttpStatus.OK);

        }
    }
}
