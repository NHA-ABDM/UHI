package in.gov.abdm.eua.userManagement.dto.phr;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)

public class GenerateOTPRequest extends ServiceResponse {

    public GenerateOTPRequest() {
        super();
    }

    private Object value;
    private Object authMode;

}