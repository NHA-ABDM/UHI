package in.gov.abdm.uhi.hspa.dto;

import lombok.Data;

@Data
public class PushNotificationRequestDTO {
    private String title;
    private String message;
    private String senderAbhaAddress;
    private String receiverAbhaAddress;
    private String providerUri;
    private String token;
    private String type;
    private String topic;
    private String gender;
    

    
    
}