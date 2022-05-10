package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Context {
	private String domain;
	private String country;
	private String city;
	private String action;
	@JsonProperty(value = "core_version")
	private String coreVersion;
	@JsonProperty(value = "consumer_id")
	private String consumerId;
	@JsonProperty(value = "consumer_uri")
	private String consumerUri;
	@JsonProperty(value = "provider_id")
	private String providerId;
	@JsonProperty(value = "provider_uri")
	private String providerUri;
	@JsonProperty(value = "transaction_id")
	private String transactionId;
	@JsonProperty(value = "message_id")
	private String messageId;
	private String timestamp;
	private String key;
	private String ttl;
}
