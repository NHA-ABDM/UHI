package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.*;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Data
@Builder
@NoArgsConstructor(access = AccessLevel.PUBLIC)
@AllArgsConstructor(access = AccessLevel.PUBLIC)
public class CreatePHRRequest {
    @NotNull(message = "SessionId is mandatory")
    private Object sessionId;
    @NotNull(message = "phrAddress is mandatory")
    private Object phrAddress;

    //	@Encryption(required = false)
//	@Password(required = false)
    private Object password;

    private Boolean isAlreadyExistedPHR;

    @NotBlank(message = "healthIdNumber cannot be empty")
    private String healthIdNumber;
    @NotBlank(message = "authMethod cannot be empty")
    private String authMethod;

}