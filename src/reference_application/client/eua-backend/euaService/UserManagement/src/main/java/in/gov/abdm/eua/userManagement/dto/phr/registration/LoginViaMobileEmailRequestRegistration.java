package in.gov.abdm.eua.userManagement.dto.phr.registration;


import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotBlank;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class LoginViaMobileEmailRequestRegistration {
    @JsonProperty("healthid")
    @NotBlank(message = "HealthId cannot be null/blank")
    private String healthId;
    @NotBlank(message = "authMethod cannot be null/blank")
    private String authMethod;
}
