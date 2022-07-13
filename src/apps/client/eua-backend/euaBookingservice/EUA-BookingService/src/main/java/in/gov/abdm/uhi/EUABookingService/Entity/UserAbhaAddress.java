package in.gov.abdm.uhi.EUABookingService.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class UserAbhaAddress {
    @Column(name = "user_abha_address_id")
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long userPhrAddressId;
    @Column(name = "phr_address")
    private String phrAddress;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName ="id")
    private User user;


}
