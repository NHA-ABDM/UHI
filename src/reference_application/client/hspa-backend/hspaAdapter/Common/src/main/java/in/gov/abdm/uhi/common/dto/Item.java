package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Item {
	private String id;
	private Quantity quantity;
	private Descriptor descriptor;
	@JsonProperty(value = "category_id")
	private String categoryId;
	@JsonProperty(value = "fulfillment_id")
	private String fulfillmentId;
	@JsonProperty(value = "provider_id")
	private String providerId;
	private Price price;
}
