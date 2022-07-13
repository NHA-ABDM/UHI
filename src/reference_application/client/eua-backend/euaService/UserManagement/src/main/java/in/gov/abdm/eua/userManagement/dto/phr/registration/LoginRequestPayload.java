package in.gov.abdm.eua.userManagement.dto.phr.registration;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class LoginRequestPayload {
    @NotNull(message = "sessionId cannot be null")
    private Object sessionId;
    @NotNull(message = "value cannot be null")
    private Object value;
}
