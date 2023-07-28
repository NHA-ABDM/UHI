package in.gov.abdm.uhi.discovery.exception;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.SpecVersion.VersionFlag;
import com.networknt.schema.ValidationMessage;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class JsonValidator {

    static ObjectMapper objectMapper = new ObjectMapper();

    private JsonValidator() {
    }

    public static String validateJson(String request, String schemaName) throws JsonProcessingException {
        Response response = Response.builder().build();
        MessageAck message = new MessageAck();
        Ack ack = Ack.builder().build();
        Error error = new Error();
        JsonSchemaFactory schemaFactory = JsonSchemaFactory.getInstance(VersionFlag.V4);
        InputStream schemaStream = ClasspathLoader.inputStreamFromClasspath(schemaName);
        return prepareAckNack(request, objectMapper, response, message, ack, error, schemaFactory, schemaStream);
    }

    private static String prepareAckNack(String request, ObjectMapper objectMapper, Response response, MessageAck message, Ack ack, Error error, JsonSchemaFactory schemaFactory, InputStream schemaStream) throws JsonProcessingException {
        JsonNode json;
            json = objectMapper.readTree(request);

        JsonSchema schema = schemaFactory.getSchema(schemaStream);
        Set<ValidationMessage> validationResult = schema.validate(json);
        List<String> erroList = new ArrayList<>();
        if (!validationResult.isEmpty()) {
            for (ValidationMessage validationMessage : validationResult) {
                erroList.add(validationMessage.getMessage().replace("$.context.", ""));
            }
            error.setMessage(erroList.toString());
            error.setCode(HttpStatus.BAD_REQUEST.value() + "");
            error.setType(HttpStatus.BAD_REQUEST.name());
            error.setPath("/" + JsonValidator.class.getSimpleName());
            ack.setStatus("NACK");

        } else {
            ack.setStatus("ACK");
        }
        message.setAck(ack);
        response.setError(error);
        response.setMessage(message);
        return objectMapper.writeValueAsString(response);
    }
}

