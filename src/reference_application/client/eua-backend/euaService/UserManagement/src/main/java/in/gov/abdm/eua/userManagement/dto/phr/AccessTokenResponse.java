package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccessTokenResponse {

    private String accessToken;

    long expiresIn;

    public AccessTokenResponse(String accessToken) {
        super();
        this.accessToken = accessToken;
    }

}
