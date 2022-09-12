package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.persistence.Column;

@EqualsAndHashCode(callSuper = true)
@Data
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class CancelRequestDTO extends ServiceResponseDTO {
    private String status;
    private String cancelReason;

}
