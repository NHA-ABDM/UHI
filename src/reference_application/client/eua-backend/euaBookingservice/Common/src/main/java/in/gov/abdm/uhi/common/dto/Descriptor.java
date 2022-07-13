package in.gov.abdm.uhi.common.dto;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
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
