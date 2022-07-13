package in.gov.abdm.eua.userManagement.dto.phr.login;

import in.gov.abdm.eua.userManagement.dto.phr.Requester;
import in.gov.abdm.eua.userManagement.dto.phr.ServiceResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.Valid;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class LoginViaMobileEmailRequestInit extends ServiceResponse {
    @NotBlank(message = "value cannot be null/blank")
    private String value;
    @NotBlank(message = "purpose cannot be null/blank")
    private String purpose;
    @NotBlank(message = "authMode cannot be null/blank")
    private String authMode;
    @NotNull(message = "requester cannot be null/blank")
    @Valid
    private Requester requester;
}
