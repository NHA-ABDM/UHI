package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;

/**
 * @author Mohit
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginPreVerificationRequest {
    @NotNull(message = "Transaction ID cannot be null")
    private Object transactionId;
    @NotNull(message = "AuthCode cannot be null")
    private Object authCode;
    @NotNull(message = "RequesterId cannot be null")
    private Object requesterId;
}
