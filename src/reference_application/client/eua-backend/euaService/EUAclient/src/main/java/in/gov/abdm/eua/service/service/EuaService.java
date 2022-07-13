package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import org.springframework.http.ResponseEntity;

public interface EuaService {

    void pushToMqGatewayTOEua(MqMessageTO message, String requestMessageId);

    void pushToMq(String searchRequest, String clientId, String action, String requestMessageId);

    MqMessageTO extractMessage(String searchRequest, String consumerId, String requestMessageId, String action);

    ResponseEntity<AckResponseDTO> getOnAckResponseResponseEntity(ObjectMapper objectMapper, String onRequest, String dhpQueryType, String requestMessageId) throws JsonProcessingException;
}
