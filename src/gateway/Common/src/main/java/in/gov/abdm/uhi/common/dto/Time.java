package in.gov.abdm.uhi.common.dto;

import lombok.Data;

@Data
public class Time {
	private String label;
	private String timestamp;
	private String duration;
	private Range range;
	private String days;
	private Schedule schedule;
}
