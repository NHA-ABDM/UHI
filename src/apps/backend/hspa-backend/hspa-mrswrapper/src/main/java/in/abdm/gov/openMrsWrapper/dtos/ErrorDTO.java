
package in.abdm.gov.openMrsWrapper.dtos;

import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.http.HttpStatus;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "type",
    "code",
    "path"
})
@Data
public class ErrorDTO {

    @JsonProperty("type")
    public String type;
    @JsonProperty("code")
    public HttpStatus code;
    @JsonProperty("path")
    public String path;

}
