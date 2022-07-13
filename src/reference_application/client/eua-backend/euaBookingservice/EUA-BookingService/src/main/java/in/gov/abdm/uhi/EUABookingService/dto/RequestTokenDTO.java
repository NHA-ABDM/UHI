package in.gov.abdm.uhi.EUABookingService.dto;

import lombok.Data;
@Data
public class RequestTokenDTO {	
  
    private String userName;    
 
    private String token;    
 
    private String deviceId;
    
    private String type;

}
