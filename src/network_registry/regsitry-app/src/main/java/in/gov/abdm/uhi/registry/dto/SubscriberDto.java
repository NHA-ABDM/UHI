package in.gov.abdm.uhi.registry.dto;

import javax.persistence.Column;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class SubscriberDto {
	private String subscriber_id;
	private String participant_id;
	private String country;
	private String city;
	private String domain;
	@JsonProperty(value = "pub_key_id")
	private String pubKeyId;
	private String signing_public_key;
	private String encr_public_key;
	private String valid_from;
	@JsonProperty(value = "valid_until")
	private String valid_to;
	private String status;
	@Column(name = "sub_type")
	private String type;
	@JsonProperty(value = "subscriber_url")
	private String subscriber_url;

}
