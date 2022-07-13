
package in.gov.abdm.eua.userManagement.dto.phr;


import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TransactionResponse extends ServiceResponse {
    @NotNull(message = "sessionId cannot be null")
    private Object sessionId;

}