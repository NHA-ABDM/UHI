package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;

import lombok.Data;

@Data
public class Provider {
	private String id;
	private Descriptor descriptor;
	private ArrayList<Category> categories;
	private ArrayList<Fulfillment> fulfillments;
	private ArrayList<Items> items;
}
