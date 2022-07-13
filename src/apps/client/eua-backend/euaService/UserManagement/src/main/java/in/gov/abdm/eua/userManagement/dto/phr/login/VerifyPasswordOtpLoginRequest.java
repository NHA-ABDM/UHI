package in.gov.abdm.eua.userManagement.dto.phr.login;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotBlank;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class VerifyPasswordOtpLoginRequest {
    @NotBlank(message = "transactionId cannot be null")
    private String transactionId;
    @NotBlank(message = "authCode cannot be null")
    private String authCode;
    @NotBlank(message = "requesterId cannot be null")
    private String requesterId;

    @NotBlank(message = "patientId cannot be blank")
    private String patientId;
}
