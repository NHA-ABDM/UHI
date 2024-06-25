package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class PushNotificationRequestDTO extends ServiceResponseDTO {
    private String title;
    @JsonProperty("message")
    private String messageString;
    private String senderAbhaAddress;
    private String receiverAbhaAddress;
    private String providerUri;
    private String token;
    private String type;
    private String topic;
    private String gender;
    private String sharedKey;
    private String contentType;
    private String consumerUrl;
    private String deviceId;
}