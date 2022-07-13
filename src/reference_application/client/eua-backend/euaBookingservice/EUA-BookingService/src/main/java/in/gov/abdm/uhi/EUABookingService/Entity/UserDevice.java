package in.gov.abdm.uhi.EUABookingService.entity;

import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "user_device", schema = "eua")
public class UserDevice {
    @Id
    @Column(name = "mac_id")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long macId;
    @Column(name = "device_name")
    private String deviceName;
    @Column(name = "device_type")
    private String deviceType;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName ="id")
    private User user;

    @OneToMany(mappedBy = "userDevice")
    private Set<Message> messages;
}
