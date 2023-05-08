package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class HeaderDTO {
    private String headers;
    private String expires;
    private String signature;
    private String created;
    private String keyId;
    private String algorithm;
}