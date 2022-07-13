package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Catalog {
	private Descriptor descriptor;
	private List<Provider> providers;
	private List<Item> items;
	private List<Fulfillment> fulfillments;
}
