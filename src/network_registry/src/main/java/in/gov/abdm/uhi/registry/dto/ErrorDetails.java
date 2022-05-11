package in.gov.abdm.uhi.registry.dto;

import java.sql.Timestamp;
import java.util.Date;

import lombok.Data;

@Data
public class ErrorDetails {
	private String message;
	private String status;
	private String path;
	private Date timestamp;
}
