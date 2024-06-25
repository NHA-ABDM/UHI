package in.gov.abdm.uhi.discovery.utility;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.discovery.exception.AuthHeaderNotFoundError;
import in.gov.abdm.uhi.discovery.exception.GatewayError;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;
import java.sql.Timestamp;
import java.util.Map;

@Component
public class GatewayUtility {

    private static final Logger LOGGER = LogManager.getLogger(GatewayUtility.class);


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
            String categorycode = getCategoryCode(request);
            String fulfillmenttype = getFulfillmentType(request);
            String itemcode = getItemCode(request);
            LOGGER.info(
                "created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, category_code:{}, fulfillment_type:{}, item_code:{}, Response:{}"
               ,new Timestamp(System.currentTimeMillis()), request.getContext().getTransactionId(),
                request.getContext().getMessageId(), request.getContext().getConsumerId(), null == request.getContext().getProviderId() ? "NA" : request.getContext().getProviderId(),
                request.getContext().getDomain(), request.getContext().getCity(), request.getContext().getAction(),
                categorycode, fulfillmenttype, itemcode,
                objectMapper.writeValueAsString(responseError));
        } catch (JsonProcessingException e) {
            LOGGER.error(e.getMessage());
        }
    }

    public void checkAuthHeader(Map<String, String> headers, Request request, String requestId) {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        if (!headers.containsKey(GlobalConstants.AUTHORIZATION)) {
            LOGGER.info("checkAuthHeader() Error: {} | Request ID: {} | Auth header not found {}",origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, headers);
            logErrorMessageForKibana(request, GatewayError.AUTH_HEADER_NOT_FOUND.getMessage(), GatewayError.AUTH_HEADER_NOT_FOUND.getCode());
            throw new AuthHeaderNotFoundError("Auth header not found.");
        }
    }

    public void checkXAuthHeader(Map<String, String> headers, Request request, String requestId) {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        if (!headers.containsKey(GlobalConstants.X_GATEWAY_AUTHORIZATION)) {
            LOGGER.info("Error: {} | Request ID: {} | Auth header not found {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, headers);
            logErrorMessageForKibana(request, GatewayError.AUTH_HEADER_NOT_FOUND.getMessage(), GatewayError.AUTH_HEADER_NOT_FOUND.getCode());
            throw new AuthHeaderNotFoundError("Auth header not found.");
        }
    }

    private String getCategoryCode(Request request){
        if(request.getMessage().getIntent() != null){
            if(request.getMessage().getIntent().getCategory() != null){
                if(request.getMessage().getIntent().getCategory().getDescriptor() != null){
                    return request.getMessage().getIntent().getCategory().getDescriptor().getCode();
                }
            }
        }
        return null;
    }

    private String getFulfillmentType(Request request){
        if(request.getMessage().getIntent() != null){
            if(request.getMessage().getIntent().getFulfillment() != null){
                return request.getMessage().getIntent().getFulfillment().getType();
            }
        }
        return null;
    }

    private String getItemCode(Request request){
        if(request.getMessage().getIntent() != null){
            if(request.getMessage().getIntent().getItem() != null){
                if(request.getMessage().getIntent().getItem().getDescriptor() != null){
                    return request.getMessage().getIntent().getItem().getDescriptor().getCode();
                }
            }
        }
        return null;
    }
}
