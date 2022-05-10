package in.gov.abdm.uhi.common.dto;

import lombok.Data;

@Data
public class Response {
	private MessageAck message;
	private Error error;
}
