package in.gov.abdm.eua.userManagement.dto.dhp;

import lombok.Data;

@Data
public class ErrorResponseDTO {
    protected String message;
    protected String code;
    protected String path;
}