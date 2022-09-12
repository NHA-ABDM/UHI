package in.gov.abdm.uhi.common.dto;

import lombok.Data;

import java.util.List;

@Data
public class Schedule {
	private String frequency;
	private List<String> holidays;
	private List<String> times;
}
