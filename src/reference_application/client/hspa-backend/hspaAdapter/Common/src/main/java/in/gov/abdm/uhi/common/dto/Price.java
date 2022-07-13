package in.gov.abdm.uhi.common.dto;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Price {
	private String currency;
	private String value;
	@JsonProperty(value = "estimated_Value")
	private String estimatedValue;
	@JsonProperty(value = "computed_Value")
	private String computedValue;
	@JsonProperty(value = "listed_Value")
	private String listedValue;
	@JsonProperty(value = "offered_Value")
	private String offeredValue;
	@JsonProperty(value = "minimum_Value")
	private String minimumValue;
	@JsonProperty(value = "maximum_Value")
	private String maximumValue;
	private List<Breakup> breakup;

}
