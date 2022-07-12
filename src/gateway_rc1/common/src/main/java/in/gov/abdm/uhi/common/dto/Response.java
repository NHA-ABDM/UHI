package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Response {
	@JsonProperty("message")
	private MessageAck message;
	private Error error;
}
