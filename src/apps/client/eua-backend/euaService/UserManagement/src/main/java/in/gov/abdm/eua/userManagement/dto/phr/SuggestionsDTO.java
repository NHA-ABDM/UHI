package in.gov.abdm.eua.userManagement.dto.phr;



import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)

public class SuggestionsDTO extends ServiceResponse {
    Set<String> suggestedPhrAddress;
}
