package in.gov.abdm.uhi.hspa.models;

import in.gov.abdm.uhi.hspa.dto.ServiceResponseDTO;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "SharedKey")
@Data
public class SharedKeyModel extends ServiceResponseDTO {
    @Id
    @Column(name = "username")
    private String userName;

    @Column(name = "publicKey")
    private String publicKey;

    @Column(name = "privateKey")
    private String privateKey;


}
