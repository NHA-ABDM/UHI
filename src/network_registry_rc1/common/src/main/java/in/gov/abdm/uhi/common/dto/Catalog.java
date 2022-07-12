package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;

import lombok.Data;

@Data
public class Catalog {
	private Descriptor descriptor;
	private ArrayList<Provider> providers;
}
