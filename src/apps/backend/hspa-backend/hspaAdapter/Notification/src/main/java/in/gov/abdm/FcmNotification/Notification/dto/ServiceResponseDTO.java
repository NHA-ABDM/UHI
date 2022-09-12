package in.gov.abdm.FcmNotification.Notification.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ServiceResponseDTO {
    protected ErrorResponseDTO error;
    protected String Response;
}
