package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Descriptor {
	private String name;
	private String code;
	private String symbol;
	@JsonProperty(value = "short_desc")
	private String shortDesc;
	@JsonProperty(value = "long_desc")
	private String longDesc;
	private Map<String, String> images;
	private String audio;
	private String render3d;
}
