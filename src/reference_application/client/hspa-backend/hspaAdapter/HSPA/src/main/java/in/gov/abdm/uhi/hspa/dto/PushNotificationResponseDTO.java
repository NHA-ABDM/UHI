package in.gov.abdm.uhi.hspa.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PushNotificationResponseDTO {
    private int status;
    private String message;

}