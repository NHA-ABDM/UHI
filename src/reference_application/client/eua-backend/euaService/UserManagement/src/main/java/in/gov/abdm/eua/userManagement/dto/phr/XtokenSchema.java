package in.gov.abdm.eua.userManagement.dto.phr;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class XtokenSchema extends ServiceResponse {
    private String expiresIn;
    private String refreshExpiresIn;
    private String refreshToken;
    private String token;
}
