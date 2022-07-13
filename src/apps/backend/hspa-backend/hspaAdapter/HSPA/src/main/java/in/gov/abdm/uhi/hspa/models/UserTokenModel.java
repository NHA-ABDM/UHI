package in.gov.abdm.uhi.hspa.models;

import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;

import javax.persistence.*;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "UserToken")
@Data
public class UserTokenModel {
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
