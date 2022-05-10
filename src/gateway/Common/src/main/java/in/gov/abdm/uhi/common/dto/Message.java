package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Message {
	private Intent intent;

	private Order order;
	@JsonProperty(value = "order_id")
	private String orderId;
	private Catalog catalog;
}
