package in.gov.abdm.uhi.EUABookingService.entity;

import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class User {
    @Id
    @Column(name = "id")
    private String id;

    @Column(name = "fullName")
    private String fullName;
    @Column(name = "first_name", nullable = false)
    private String firstName;
    @Column(name = "has_transsaction_pin", nullable = false)
    private Boolean hasTransactionPin;
    @Column(name = "middle_name")
    private String middleName;
    @Column(name = "last_name")
    private String lastName;
    @Column(name = "health_id_number")
    private String healthIdNumber;
    @Column(name = "health_id")
    private String healthId;
    @Column(name = "email")
    private String email;
    @Column(name = "password")
    private String password;
    @Column(name = "mobile")
    private String mobile;

    @Column(name = "address")
    private String address;

    @Column(name ="gender")
    private String gender;

    @Column(name = "date_of_birth")
    private Integer dateOfBirth;

    @Column(name = "month_of_birth")
    private Integer monthOfBirth;

    @Column(name = "year_of_birth")
    private Integer yearOfBirth;

    @Column(name = "profile_photo", length = 50000)
    private String profilePhoto;

    @Column(name = "aadhar_verified")
    private Boolean aadhaarVerified;

    @Column(name = "kyc_photo", length = 20000)
    private String kycPhoto;

    @Column(name = "is_kyc_verified")
    private Boolean kycVerified;

    @Column(name = "is_email_verified")
    private Boolean emailVerified;

    @Column(name = "is_mobile_verified")
    private Boolean mobileVerified;

    @Column(name = "verification_type")
    private String verificationType;

    @Column(name = "verification_status")
    private String verificationStatus;

    @Column(name = "state_name")
    private String stateName;

    @Column(name = "state_code")
    private String stateCode;

    @Column(name = "district_name")
    private String districtName;

    @Column(name = "district_code")
    private String districtCode;

    @Column(name = "kycDocument_type")
    private String kycDocumentType;

    @Column(name = "kyc_status")
    private String kycStatus;

    @Column(name = "country_name")
    private String countryName;

    @Column(name = "pincode")
    private String pincode;



    @ElementCollection
    private Set<String> authMethods;


    @OneToMany(mappedBy = "user")
    private Set<Orders> orders;

    @OneToMany(mappedBy = "user")
    private Set<Payments> payments;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<UserRefreshToken> userRefreshTokens;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<UserAbhaAddress> user_abhaAddresses;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private Set<Address> addresses;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<UserDevice> userDevices;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<Message> messages;

}
