package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import lombok.Data;

@Data
public class Agent {
	private String id;
	private String name;
	private String image;
	private String dob;
	private String gender;
	private String cred;
	private Map<String, String> tags;
	private String phone;
	private String email;
}
