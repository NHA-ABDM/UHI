package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;


@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class Person {
    private String id;
    private String name;
    private String gender;
    private String image;
    private String cred;
    private Map<String, String> tags;
    private String dob;
    private Short dayOfBirth;
    private Short monthOfBirth;
    private Integer yearOfBirth;
    private Descriptor descriptor;
}
