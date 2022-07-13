package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class OtpRequestForXToken {
    @NotBlank(message = "Otp cannot be blank")
    private String otp;
    @NotBlank(message = "txnId cannot be blank")
    private String txnId;
    @NotNull(message = "mapppedPhrAddress cannot be null")
    private String mappedPhrAddress;

    @NotNull(message = "Preferred is required")
    private Boolean preferred;

}
