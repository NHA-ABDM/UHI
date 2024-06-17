package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Response;
import org.springframework.http.ResponseEntity;

public interface EuaService {


    ResponseEntity<Response> getOnAckResponseResponseEntity(ObjectMapper objectMapper, String onRequest, String dhpQueryType, String requestMessageId) throws JsonProcessingException;
}
