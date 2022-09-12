package in.gov.abdm.uhi.common.dto;

import lombok.Data;

import java.util.Map;

@Data
public class Intent {
	private Provider provider;

	private Item item;

	private Fulfillment fulfillment;

	private Category category;

	private Map<String, String> tags;

	private Chat chat;
}
