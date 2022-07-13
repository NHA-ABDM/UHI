package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
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
