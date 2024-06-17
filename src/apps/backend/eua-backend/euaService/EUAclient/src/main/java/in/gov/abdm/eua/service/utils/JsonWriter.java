package in.gov.abdm.eua.service.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class JsonWriter {

    private static final ObjectMapper JSON = new ObjectMapper();

    private JsonWriter() {
    }

    public static String write(Object value) throws JsonProcessingException {
        return JsonWriter.JSON.writeValueAsString(value);

    }

}
