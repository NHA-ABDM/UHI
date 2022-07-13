package in.gov.abdm.eua.service.dto.dhp;


import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.Message;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class EuaRequestBody {
    private Context context;
    private Message message;
}
