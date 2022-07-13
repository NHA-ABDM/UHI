package in.gov.abdm.uhi.common.dto;

import java.util.List;

import lombok.Data;

@Data
public class Schedule {
	private String frequency;
	private List<String> holidays;
	private List<String> times;
}
