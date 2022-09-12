package in.gov.abdm.uhi.EUABookingService.notification;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PushNotificationRequest {
    private String title;
    private String message;
    private String senderAbhaAddress;
    private String receiverAbhaAddress;
    private String providerUri;
    private String token;
    private String type;
    private String topic;
    private String gender;
    private String sharedKey;
    private String contentType;
}