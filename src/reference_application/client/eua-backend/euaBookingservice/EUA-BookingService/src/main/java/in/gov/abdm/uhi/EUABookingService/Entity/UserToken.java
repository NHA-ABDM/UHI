package in.gov.abdm.uhi.EUABookingService.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class UserToken {
    @Id   
    @Column(name = "userid")
    private String userId;
    
    @Column(name = "username")
    private String userName;
    
    @Column(name = "token")
    private String token;
    
    @Column(name = "deviceid")
    private String deviceId;
  

}
