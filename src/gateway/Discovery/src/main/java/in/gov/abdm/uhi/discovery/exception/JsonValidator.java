package in.gov.abdm.uhi.discovery.exception;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.ValidationMessage;
import com.networknt.schema.SpecVersion.VersionFlag;

import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.utility.JsonWriter;
import reactor.core.publisher.Mono;

public class JsonValidator {

	public static Mono<String> validateJson(String request,String schemaName) {
		ObjectMapper objectMapper = new ObjectMapper();
		JsonSchemaFactory schemaFactory = JsonSchemaFactory.getInstance(VersionFlag.V4);
		InputStream schemaStream = ClasspathLoader.inputStreamFromClasspath(schemaName);
		{
			JsonNode json = null;
			try {
				json = objectMapper.readTree(request);
			} catch (IOException e) {
				e.printStackTrace();
			}
			JsonSchema schema = schemaFactory.getSchema(schemaStream);
			Set<ValidationMessage> validationResult = schema.validate(json);
			List<String>erroList=new ArrayList<String>();
			if (!validationResult.isEmpty()) {
				Error error = new Error();
				for (ValidationMessage validationMessage : validationResult) {
					erroList.add(validationMessage.getMessage().toString().replace("$.context.", ""));
				}
				error.setMessage(erroList.toString());
				Response response = new Response();
				MessageAck message = new MessageAck();
				error.setCode(HttpStatus.BAD_REQUEST.value() + "");
				error.setType(HttpStatus.BAD_REQUEST.name());
				Ack ack = new Ack();
				ack.setStatus("NACK");
				message.setAck(ack);
				response.setError(error);
				response.setMessage(message);
				return JsonWriter.write(response);
			}
	
		return null;
			}
	}
}

