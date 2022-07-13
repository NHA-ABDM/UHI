package in.gov.abdm.uhi.hspa.models;

import in.gov.abdm.uhi.hspa.dto.ServiceResponseDTO;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "ChatUser")
@Data
public class ChatUserModel extends ServiceResponseDTO {
    @Id   
    @Column(name = "userid")
    private String userId;
    
    @Column(name = "username")
    private String userName;
    
    @Column(name = "image", length = 50000)
    private String image;   

}
