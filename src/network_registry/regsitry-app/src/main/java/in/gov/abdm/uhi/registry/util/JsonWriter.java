package in.gov.abdm.uhi.registry.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import reactor.core.publisher.Mono;

public class JsonWriter {

  private static final ObjectMapper JSON = new ObjectMapper();

  public static String write(Object value) throws JsonProcessingException {
  return JsonWriter.JSON.writeValueAsString(value);

  }

}
