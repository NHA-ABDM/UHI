package in.gov.abdm.FcmNotification.Notification.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class RequestSharedKeyDTO extends ServiceResponseDTO {

    private String userName;

    private String publicKey;

    private String privateKey;


}
