package in.gov.abdm.uhi.discovery.utility;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import reactor.core.publisher.Mono;

public class JsonWriter {

    private static final ObjectMapper JSON = new ObjectMapper();

    private JsonWriter() {
    }

    public static Mono<String> write(Object value) {
        try {
            return Mono.just(JsonWriter.JSON.writeValueAsString(value));
        } catch (JsonProcessingException e) {
            return Mono.error(e);
        }
    }

}
