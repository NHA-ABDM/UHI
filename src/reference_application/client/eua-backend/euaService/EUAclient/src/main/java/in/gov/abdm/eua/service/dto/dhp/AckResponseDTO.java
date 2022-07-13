package in.gov.abdm.eua.service.dto.dhp;

import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Error;
import lombok.Data;

@Data
public class AckResponseDTO {
    private MessageAck message;
    private Error error;
}
