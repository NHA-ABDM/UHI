package in.gov.abdm.FcmNotification.Notification.model;

import in.gov.abdm.FcmNotification.Notification.utils.ConstantsUtils;
import lombok.Data;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

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
