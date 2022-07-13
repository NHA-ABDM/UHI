package in.gov.abdm.eua.userManagement.dto.phr;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)

public class JwtResponse extends ServiceResponse {


    private String token;

    private Long expiresIn;

    private String refreshToken;

    private Long refreshExpiresIn;

    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    private String phrAdress;

    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    private String firstName;

    private String txnId;
}