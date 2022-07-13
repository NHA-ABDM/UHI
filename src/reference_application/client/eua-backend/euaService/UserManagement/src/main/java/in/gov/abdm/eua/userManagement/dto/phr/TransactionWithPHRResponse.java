package in.gov.abdm.eua.userManagement.dto.phr;


import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)

public class TransactionWithPHRResponse extends ServiceResponse {


    private Object sessionId;

    private Set<String> mappedPhrAddress;

}