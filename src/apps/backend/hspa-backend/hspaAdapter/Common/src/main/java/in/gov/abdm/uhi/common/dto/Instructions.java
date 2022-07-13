package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Instructions {
	private String name;
	private String code;
	private String symbol;
	@JsonProperty(value = "short_desc")
	private String shortDesc;
	@JsonProperty(value = "long_desc")
	private String longDesc;
	private Map<String, String> images;
	private String audio;
	@JsonProperty("3d_render")
	private String render3d;
}
