package in.gov.abdm.eua.service.dto.dhp;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Error;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown=true)
public class AckResponseDTO {
    private MessageAck message;
    private Error error;
}
