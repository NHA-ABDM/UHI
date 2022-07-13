package in.gov.abdm.uhi.common.dto;

import java.lang.reflect.Field;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
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
