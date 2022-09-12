package in.gov.abdm.uhi.common.dto;

import lombok.Data;

import java.util.Map;

@Data
public class Contact {
	private String phone;
	private String email;
	private Map<String, String> tags;
}
