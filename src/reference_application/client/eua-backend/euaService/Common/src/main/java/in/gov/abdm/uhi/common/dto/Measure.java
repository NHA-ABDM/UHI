package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Measure {
	private String type;
	private long value;
	@JsonProperty(value = "estimated_value")
	private long estimatedValue;
	@JsonProperty(value = "computed_value")
	private long computedValue;
	private Range range;
	private String unit;
}
