package in.gov.abdm.FcmNotification.Notification.model;


import lombok.Data;

import javax.persistence.*;

@Entity
@Table(schema = "eua")
@Data
public class SharedKey {
    @Id    
    @Column(name = "username")
    private String userName;
    
    @Column(name = "publicKey")
    private String publicKey;
    
    @Column(name = "privateKey")
    private String privateKey;
   
  

}
