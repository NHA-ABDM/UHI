package in.gov.abdm.eua.service.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.GlobalConstants;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.eua.service.service.EuaService;
import in.gov.abdm.eua.service.service.MQConsumerService;
import in.gov.abdm.eua.service.utils.EuaUtility;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;

@Service
@Slf4j
public class EuaServiceImpl implements EuaService {
    private static final Logger LOGGER = LoggerFactory.getLogger(EuaServiceImpl.class);


    final
    EuaUtility euaUtility;

    private final MQConsumerService mqService;


    public EuaServiceImpl(EuaUtility euaUtility, MQConsumerService mqService) {
        this.euaUtility = euaUtility;
        this.mqService = mqService;
    }

    public static Response generateAck() {

        MessageAck msz =  MessageAck.builder().ack(Ack.builder().status("ACK").build()).build();
        return Response.builder().message(msz).build();
    }


    @Override
    public ResponseEntity<Response> getOnAckResponseResponseEntity(ObjectMapper objectMapper, String onRequest, String dhpQueryType, String requestMessageId) {

            LOGGER.info("Success... Message ID is {}", requestMessageId);
            Response onSearchAck = generateAck();
            return new ResponseEntity<>(onSearchAck, HttpStatus.OK);


    }

    public void verifyHeadersAndProceed(String onSearchRequestString, Map<String, String> headers, Request onSearchRequest, String requestMessageId, String consumerId, String action) throws JsonProcessingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException, SignatureException, InvalidKeySpecException {
        MqMessageTO message = mqService.extractMessage(onSearchRequestString, consumerId, requestMessageId, action);
        String checkForXgatewayHeaderIsNull = headers.get(GlobalConstants.X_GATEWAY_AUTHORIZATION.toLowerCase()) == null ? null : GlobalConstants.X_GATEWAY_AUTHORIZATION.toLowerCase();
        String headerName = headers.get(GlobalConstants.AUTHORIZATION.toLowerCase())==null ? checkForXgatewayHeaderIsNull : GlobalConstants.AUTHORIZATION.toLowerCase();
        euaUtility.checkAuthHeader(headers, onSearchRequest,headerName);
        mqService.processResponse(onSearchRequestString, onSearchRequest,headerName, headers, message);
    }



}
