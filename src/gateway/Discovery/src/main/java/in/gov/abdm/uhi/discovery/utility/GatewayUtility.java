package in.gov.abdm.uhi.discovery.utility;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.discovery.exception.AuthHeaderNotFoundError;
import in.gov.abdm.uhi.discovery.exception.GatewayError;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.sql.Timestamp;
import java.util.Map;

@Component
public class GatewayUtility {

    private static final Logger LOGGER = LoggerFactory.getLogger(GatewayUtility.class);


    final
    ObjectMapper objectMapper;


    public GatewayUtility(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public Mono<String> generateNack(String message, String code, Request request) {
        logErrorMessageForKibana(request,message, code);
        Response resp = generateNackWithoutMono(message, code);
        return JsonWriter.write(resp);
    }

    private static Response generateNackWithoutMono(String message, String code) {
        Error error = Error.builder().message(message).code(String.valueOf(code)).build();
        return Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(error).build();
    }

    public String generateAck() throws JsonProcessingException {
        Response resp = Response.builder().message(MessageAck.builder().ack(Ack.builder().status("ACK").build()).build()).build();
            return objectMapper.writeValueAsString(resp);
    }

    public void logErrorMessageForKibana(Request request, String error, String code) {
        Response responseError = generateNackWithoutMono(error, GatewayError.INTERNAL_SERVER_ERROR.getCode());
        try {
            LOGGER.info(
                    "created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Response:{}"
                   ,new Timestamp(System.currentTimeMillis()), request.getContext().getTransactionId(),
                    request.getContext().getMessageId(), request.getContext().getConsumerId(), null == request.getContext().getProviderId() ? "NA" : request.getContext().getProviderId(),
                    request.getContext().getDomain(), request.getContext().getCity(), request.getContext().getAction(),
                    objectMapper.writeValueAsString(responseError));
        } catch (JsonProcessingException e) {
            LOGGER.error(e.getMessage());
        }
    }

    public void checkAuthHeader(Map<String, String> headers, Request request) {
        if (!headers.containsKey(GlobalConstants.AUTHORIZATION)) {
            logErrorMessageForKibana(request, GatewayError.AUTH_HEADER_NOT_FOUND.getMessage(), GatewayError.AUTH_HEADER_NOT_FOUND.getCode());
            throw new AuthHeaderNotFoundError("Auth header not found.");
        }
    }
}
