package in.gov.abdm.uhi.EUABookingService.notification;

import com.fasterxml.jackson.annotation.JsonInclude;

import in.gov.abdm.uhi.EUABookingService.dto.ServiceResponseDTO;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PushNotificationResponse extends ServiceResponseDTO {
    private int status;
    private String message;
    
    
    public PushNotificationResponse() {
    }
    
    public PushNotificationResponse(int status, String message) {
        this.status = status;
        this.message = message;
    }
    public int getStatus() {
        return status;
    }
    public void setStatus(int status) {
        this.status = status;
    }
    public String getMessage() {
        return message;
    }
    public void setMessage(String message) {
        this.message = message;
    }
}