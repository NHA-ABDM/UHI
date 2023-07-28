package in.gov.abdm.uhi.registry.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SearchDto {

	@JsonProperty(value = "subscriber_id")
	private String subscriberId;
	// @NotBlank(message = "Type should not be blank!")
	private String type;
	// @NotBlank(message = "Domain should not be blank!")
	public String domain;
//	@NotBlank(message = "Country should not be blank!")
	// @Size(min = 3, max = 3,message = "Coutry should be first 3 digit!")
	public String country;
	// @NotBlank(message = "City should not be blank!")
	public String city;
	@JsonProperty(value = "pub_key_id")
	private String publicKeyId;
	private String status;

}
