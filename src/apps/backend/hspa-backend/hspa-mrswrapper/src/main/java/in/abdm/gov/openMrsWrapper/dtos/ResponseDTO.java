package in.abdm.gov.openMrsWrapper.dtos;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class ResponseDTO extends ServiceResponseDTO {
    private String response;
}
