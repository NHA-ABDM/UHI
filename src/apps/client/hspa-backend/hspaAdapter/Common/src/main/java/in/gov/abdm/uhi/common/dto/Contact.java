package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import lombok.Data;

@Data
public class Contact {
	private String phone;
	private String email;
	private Map<String, String> tags;
}
