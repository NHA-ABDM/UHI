package in.gov.abdm.uhi.registry.dto;

import lombok.Data;

@Data

public class SubscribeResponseDto {
	private String status;

	public SubscribeResponseDto() {

	}

	public SubscribeResponseDto(String status) {
		this.status = status;
	}
}
