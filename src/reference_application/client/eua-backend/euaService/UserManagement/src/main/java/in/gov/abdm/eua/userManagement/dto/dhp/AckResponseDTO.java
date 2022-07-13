package in.gov.abdm.eua.userManagement.dto.dhp;

import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import lombok.Data;

@Data
public class AckResponseDTO {
    private MessageAck message;
    private Error error;
}
