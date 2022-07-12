package in.gov.abdm.uhi.common.dto;

import lombok.Data;

@Data
public class Payment {
	private String uri;
	private String type;
	private String status;
}
