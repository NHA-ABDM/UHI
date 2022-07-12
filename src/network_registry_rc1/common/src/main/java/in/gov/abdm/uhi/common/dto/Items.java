package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Items {
	private String id;
	private Quantity quantity;
	private Descriptor descriptor;
	@JsonProperty(value = "category_id")
	private String categoryId;
	@JsonProperty(value = "fulfillment_id")
	private String fulfillmentId;
	@JsonProperty(value = "provider_id")
	private String providerId;
}
