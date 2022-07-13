package in.gov.abdm.uhi.hspa.dto;

import lombok.Data;

@Data
public class ErrorResponseDTO {
    protected String errorString;
    protected String code;
    protected String path;
}
