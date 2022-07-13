package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class State {
	private Descriptor descriptor;
	@JsonProperty(value = "updated_at")
	private String updatedAt;
	@JsonProperty(value = "updated_by")
	private String updatedBy;
}
