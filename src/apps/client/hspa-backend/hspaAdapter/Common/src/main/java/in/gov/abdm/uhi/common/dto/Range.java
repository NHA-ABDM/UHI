package in.gov.abdm.uhi.common.dto;

import lombok.Data;

@Data
public class Range {
	private String start;
	private String end;
	private Long min;
	private Long max;
}
