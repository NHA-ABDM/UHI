package in.gov.abdm.uhi.hspa.dto;

import lombok.Data;

@Data
public class RequestTokenDTO {
  
    private String userName;    
 
    private String token;    
 
    private String deviceId;
    
    private String type;

}
