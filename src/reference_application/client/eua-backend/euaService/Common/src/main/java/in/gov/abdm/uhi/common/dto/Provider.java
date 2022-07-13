package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Provider {
	private String id;
	private Descriptor descriptor;
	private ArrayList<Category> categories;
	private ArrayList<Fulfillment> fulfillments;
	private ArrayList<Items> items;
}
