package in.gov.abdm.eua.service.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.GlobalConstants;
import in.gov.abdm.eua.service.exceptions.AuthHeaderNotFoundError;
import in.gov.abdm.eua.service.exceptions.EuaError;
import in.gov.abdm.uhi.common.dto.*;

import in.gov.abdm.uhi.common.dto.Error;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
public class EuaUtility {

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    private static final Logger LOGGER = LoggerFactory.getLogger(EuaUtility.class);

    final
    ObjectMapper objectMapper;

    public EuaUtility(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    private static final int MAX_SIZE = 50 * 1024; // 50 KB

    public static void logErrorMessageForKibana(Request request, String error, String className) {
        LOGGER.error(
                "{}::error::onErrorResume::created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, domain:{}, city:{}, action:{}, Error:{}",
                className,new Timestamp(System.currentTimeMillis()), request.getContext().getTransactionId(),
                request.getContext().getMessageId(), request.getContext().getConsumerId(),
                request.getContext().getDomain(), request.getContext().getCity(), request.getContext().getAction(),
               error);
    }

    public void checkAuthHeader(Map<String, String> headers, Request request, String headerName) {
        if(Boolean.parseBoolean(isHeaderEnabled) && (headerName == null || !headers.containsKey(headerName))) {
                EuaUtility.logErrorMessageForKibana(request, EuaError.AUTH_HEADER_NOT_FOUND.getMessage(), GlobalConstants.EUA_UTILITY);
                throw new AuthHeaderNotFoundError("Auth header not found.");

        }
    }

    public String generateNack(String message, String code, Request request) throws JsonProcessingException {
        logErrorMessageForKibana(request, message, GlobalConstants.EUA_UTILITY);
        Error error = Error.builder().message(message).code(String.valueOf(code)).build();
        Response resp = Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(error).build();
        return JsonWriter.write(resp);
    }
    public String generateNackWithoutKibana(String message, String code) throws JsonProcessingException {
        Error error = Error.builder().message(message).code(String.valueOf(code)).build();
        Response resp = Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(error).build();
        return JsonWriter.write(resp);
    }

    public String generateAck() throws JsonProcessingException {
        Response resp = Response.builder().message(MessageAck.builder().ack(Ack.builder().status("ACK").build()).build()).build();
        return objectMapper.writeValueAsString(resp);
    }


    public Request getEuaRequestBody(String request) throws JsonProcessingException {
        return objectMapper.readValue(request, Request.class);
    }



        public List<Request> splitJsonFile(String jsonResponse) throws IOException {
            ObjectMapper objectMapper = new ObjectMapper();
            List<Request> responseData = new ArrayList<>();
            Request jsonData = objectMapper.readValue(jsonResponse, Request.class);

            int contextSize = objectMapper.writeValueAsBytes(jsonData.getContext()).length;
            int currentSize = contextSize;

            List<Provider> currentProviders = new ArrayList<>();
            int chunkIndex = 1;

            for (Provider provider : jsonData.getMessage().getCatalog().getProviders()) {
                int providerSize = objectMapper.writeValueAsBytes(provider).length;

                if (currentSize + providerSize < MAX_SIZE) {
                    currentProviders.add(provider);
                    currentSize += providerSize;
                } else {
                    responseData.add(saveChunk(jsonData, new ArrayList<>(currentProviders), chunkIndex));
                    chunkIndex++;
                    currentProviders.clear();
                    currentProviders.add(provider);
                    currentSize = contextSize + providerSize;
                }
            }

            if (!currentProviders.isEmpty()) {
               responseData.add(saveChunk(jsonData,  new ArrayList<>(currentProviders), chunkIndex));
            }

            return responseData;
        }

        private Request saveChunk(Request jsonData, List<Provider> providers, int chunkIndex) throws IOException {
            Request chunkData = new Request();
            chunkData.setContext(jsonData.getContext());

            chunkData.setMessage(new Message());
            chunkData.getMessage().setCatalog(new Catalog());
            chunkData.getMessage().getCatalog().setDescriptor(jsonData.getMessage().getCatalog().getDescriptor());
            chunkData.getMessage().getCatalog().setProviders(providers);

          return chunkData;
        }
    }

