package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Billing {
	private String name;
	private Organization organization;
	private Address address;
	private String email;
	private String phone;
	@JsonProperty(value = "tax_number")
	private String taxNumber;
	private Time time;
	@JsonProperty(value = "created_at")
	private String createdAt;
	@JsonProperty(value = "updated_at")
	private String updatedAt;
}
