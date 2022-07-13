package in.gov.abdm.eua.userManagement.dto.phr;


import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)
public class LoginViaMobileEmailRequestResponse extends ServiceResponse {
    @NotNull(message = "TransactionId cannot be null")
    private Object transactionId;
    @NotNull(message = "TransactionId cannot be null")
    private String requesterId;
    @NotBlank(message = "TransactionId cannot be null")
    private String authMode;


}
