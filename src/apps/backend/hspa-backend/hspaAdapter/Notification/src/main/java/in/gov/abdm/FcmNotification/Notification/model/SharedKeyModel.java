package in.gov.abdm.FcmNotification.Notification.model;

import in.gov.abdm.FcmNotification.Notification.utils.ConstantsUtils;
import lombok.Data;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "SharedKey")
@Data
public class SharedKeyModel {
    @Id    
    @Column(name = "username")
    private String userName;
    
    @Column(name = "publicKey")
    private String publicKey;
    
    @Column(name = "privateKey")
    private String privateKey;
  

}
