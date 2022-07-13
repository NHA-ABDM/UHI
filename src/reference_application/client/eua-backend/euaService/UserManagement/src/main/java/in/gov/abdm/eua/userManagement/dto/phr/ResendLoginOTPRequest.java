package in.gov.abdm.eua.userManagement.dto.phr;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
public class ResendLoginOTPRequest {
    private String txnId;

    private String authMethod;


}
