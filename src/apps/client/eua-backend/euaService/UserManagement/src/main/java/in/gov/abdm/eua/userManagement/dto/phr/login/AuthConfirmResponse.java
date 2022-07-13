package in.gov.abdm.eua.userManagement.dto.phr.login;

import com.fasterxml.jackson.annotation.JsonInclude;
import in.gov.abdm.eua.userManagement.dto.phr.ServiceResponse;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuthConfirmResponse extends ServiceResponse {
    private String token;
}
