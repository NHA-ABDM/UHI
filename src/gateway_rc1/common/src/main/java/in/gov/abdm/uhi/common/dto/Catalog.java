package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class Catalog {
	private Descriptor descriptor;
	private ArrayList<Provider> providers;
	private List<Item> items;
	private List<Fulfillment> fulfillments;
}
