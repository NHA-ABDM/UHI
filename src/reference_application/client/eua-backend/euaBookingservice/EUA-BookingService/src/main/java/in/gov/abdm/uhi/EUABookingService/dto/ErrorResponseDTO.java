package in.gov.abdm.uhi.EUABookingService.dto;

import lombok.Data;

@Data
public class ErrorResponseDTO {
    protected String errorString;
    protected String code;
    protected String path;
}