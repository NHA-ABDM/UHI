package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.*;

@Data
@Builder
@NoArgsConstructor(access = AccessLevel.PUBLIC)
@AllArgsConstructor(access = AccessLevel.PUBLIC)
public class VerifyOTPRequest {

    private Object sessionId;
    private Object value;

}