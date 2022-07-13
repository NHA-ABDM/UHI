package in.gov.abdm.eua.userManagement.dto.phr;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class TransactionIdAadhar extends ServiceResponse {
    private String txnId;
}
