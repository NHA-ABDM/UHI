
package in.gov.abdm.eua.userManagement.dto.phr;


import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;

import javax.validation.constraints.NotBlank;

@EqualsAndHashCode(callSuper = true)
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)
public class LoginResendOtp extends ServiceResponse {
    @NotBlank(message = "transactionId cannot be null/blank")
    private String transactionId;
}
