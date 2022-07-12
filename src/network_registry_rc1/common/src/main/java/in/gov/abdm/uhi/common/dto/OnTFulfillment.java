package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class OnTFulfillment {
	private String id;
	private String type;
	@JsonProperty(value = "provider_id")
	private String providerId;
	private State state;
	private Boolean tracking;
	private Customer customer;
	private Agent agent;
	private Person person;
	private Contact contact;
	private Start start;
	private End end;
	private Map<String, String> tags;
	private Time time;
	private Quote quote;
}
