package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.NotBlank;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class Requester {
    @NotBlank(message = "Requester type cannot be null/blank")
    private String type;
    @NotBlank(message = "Requester ID cannot be null/blank")
    private String id;
}