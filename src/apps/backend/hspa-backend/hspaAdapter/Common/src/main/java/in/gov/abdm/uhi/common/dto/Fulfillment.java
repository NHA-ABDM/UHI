package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class Fulfillment {
    private String id;
    private String type;
    @JsonProperty(value = "provider_id")
    private String providerId;
    private State state;
    private Boolean tracking;
    private Customer customer;
    private Agent agent;
    private Person person;
    private Contact contact;
    private Start start;
    private End end;
    private Map<String, String> tags;
    private Time time;
    private Quote quote;
}
