package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import lombok.Data;

@Data
public class Person {
	private String id;
	private String name;
	private String gender;
	private String image;
	private String cred;
	private Map<String, String> tags;
	private String dob;
	private Descriptor descriptor;
}
