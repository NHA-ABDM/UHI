package in.gov.abdm.eua.userManagement.dto.phr.login;

import com.fasterxml.jackson.annotation.JsonInclude;
import in.gov.abdm.eua.userManagement.dto.phr.ServiceResponse;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotNull;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SearchPhrAuthResponse extends ServiceResponse {
    private Set<String> authMethods;
    @NotNull(message = "phrAddress cannot be null")
    private Object phrAddress;
}
