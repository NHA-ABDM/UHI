package in.gov.abdm.uhi.registry.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SearchDto {

	@JsonProperty(value = "subscriber_id")
	private String subscriberId;
	private String type;
	public String domain;

	public String country;
	public String city;
	@JsonProperty(value = "pub_key_id")
	private String publicKeyId;

	@JsonProperty(value = "subscriber_url")
	private String subscriberUrl;

	private String status;

}
