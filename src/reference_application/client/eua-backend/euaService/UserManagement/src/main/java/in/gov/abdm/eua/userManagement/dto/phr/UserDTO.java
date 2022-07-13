package in.gov.abdm.eua.userManagement.dto.phr;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.JsonNode;
import in.gov.abdm.eua.userManagement.dto.dhp.ServiceResponseDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class UserDTO extends ServiceResponseDTO {
    private Long userId;
    private String firstName;
    private String middleName;
    private String lastName;
    private String healthIdNumber;
    private String healthId;
    private String email;
    private String password;
    private String mobile;
    private String dayOfBirth;
    private String monthOfBirth;
    private String yearOfBirth;
    private String profilePhoto;
    private String aadhaarVerified;
    private String kycPhoto;
    private Boolean kycVerified;
    private Boolean emailVerified;
    private Boolean mobileVerified;
    private String verificationType;
    private String verificationStatus;
    private Set<String> authMethods;
    private Long addressId;
    private String stateCode;
    private String stateName;
    private String districtCode;
    private String districtName;
    private String countryCode;
    private String townName;
    private String townCode;
    private String subdistrictName;
    private String subDistrictCode;
    private String wardName;
    private String wardCode;
    private String villageName;
    private String villageCode;
    private String pincode;
    private String address;
    private String gender;
    private String name;
    @JsonProperty(value = "new")
    private Boolean newKey;
    private Set<String> phrAddress;
    private JsonNode tags;
}
