package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class State {
	private Descriptor descriptor;
	@JsonProperty(value = "updated_at")
	private String updatedAt;
	@JsonProperty(value = "updated_by")
	private String updatedBy;
}
