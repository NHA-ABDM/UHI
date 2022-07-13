package in.gov.abdm.eua.userManagement.dto.phr.login;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class SearchByHealthIdNumberRequest {

    @NotNull(message = "healthIdNumber cannot be null")
    private Object healthIdNumber;
    @NotNull(message = "yearOfBirth")
    private Object yearOfBirth;

}
