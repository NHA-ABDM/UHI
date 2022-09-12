package in.gov.abdm.uhi.hspa.models;

import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "PublicKey")
@Data
public class PublicKeyModel {
    @Id    
    @Column(name = "username")
    private String userName;
    
    @Column(name = "publicKey")
    private String publicKey;
   
  

}
