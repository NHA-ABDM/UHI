package in.gov.abdm.uhi.common.dto;

import lombok.Data;

import java.util.ArrayList;

@Data
public class Provider {
	private String id;
	private Descriptor descriptor;
	private ArrayList<Category> categories;
	private ArrayList<Fulfillment> fulfillments;
	private ArrayList<Items> items;
}
