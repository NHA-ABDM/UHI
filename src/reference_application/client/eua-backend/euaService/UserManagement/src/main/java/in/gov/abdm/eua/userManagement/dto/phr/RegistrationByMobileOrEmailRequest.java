package in.gov.abdm.eua.userManagement.dto.phr;


import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import in.gov.abdm.eua.userManagement.dto.dhp.ServiceResponseDTO;
import lombok.*;

@EqualsAndHashCode(callSuper = true)
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)
public class RegistrationByMobileOrEmailRequest extends ServiceResponseDTO {
    private Object sessionId;
    private String fullName;
    private NamePhrRegistration name;
    private DateOfBirthRegistrationPhr dateOfBirth;
    private String gender;
    private String stateCode;
    private String districtCode;
    private String email;
    private String mobile;
    @JsonProperty("pincode")
    private String pinCode;
    private String address;
    @JsonProperty("id")
    private String id;
    private Boolean hasTransactionPin;
    private String healthId;
    private String stateName;
    private String districtName;
    private Boolean aadhaarVerified;
    private String profilePhoto;
    private String kycDocumentType;
    private String kycStatus;
    private Boolean mobileVerified;
    private Boolean emailVerified;
    private String countryName;




    @Data
    @ToString
    @AllArgsConstructor
    @NoArgsConstructor
    public static class NamePhrRegistration {
        private String first;
        private String middle;
        private String last;
    }

    @Data
    @ToString
    @AllArgsConstructor
    @NoArgsConstructor
    public static class DateOfBirthRegistrationPhr {
        @JsonProperty("date")
        private Integer dateOfBirth;
        @JsonProperty("month")
        private Integer monthOfBirth;
        @JsonProperty("year")
        private Integer yearOfBirth;
    }
}
