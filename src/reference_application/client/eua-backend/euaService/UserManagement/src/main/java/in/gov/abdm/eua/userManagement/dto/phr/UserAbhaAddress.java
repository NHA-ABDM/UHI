package in.gov.abdm.eua.userManagement.dto.phr;

import in.gov.abdm.eua.userManagement.constants.ConstantsUtils;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

@Data
public class UserAbhaAddress {
    private UserDTO user;
    @NotBlank(message = "PhrAddress cannot be blank")
    @Pattern(regexp = ConstantsUtils.PHR_ADDRESS_PATTERN, message = "Invalid PhrAddress")
    private String phrAddress;
}
