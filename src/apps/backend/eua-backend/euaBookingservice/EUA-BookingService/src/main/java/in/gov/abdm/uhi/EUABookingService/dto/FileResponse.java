package in.gov.abdm.uhi.EUABookingService.dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FileResponse {
	private String fileName;
	private String message;

}
