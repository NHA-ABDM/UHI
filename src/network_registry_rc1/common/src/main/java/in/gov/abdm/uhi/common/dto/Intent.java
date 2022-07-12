package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import lombok.Data;

@Data
public class Intent {
	private Provider provider;

	private Item item;

	private Fulfillment fulfillment;

	private Category category;

	private Map<String, String> tags;
}
