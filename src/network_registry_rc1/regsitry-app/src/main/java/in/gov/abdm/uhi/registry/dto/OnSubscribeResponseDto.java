package in.gov.abdm.uhi.registry.dto;

import lombok.Data;

@Data
public class OnSubscribeResponseDto {
	private String answer;

	public OnSubscribeResponseDto() {

	}

	public OnSubscribeResponseDto(String answer) {
		this.answer = answer;

	}
}
