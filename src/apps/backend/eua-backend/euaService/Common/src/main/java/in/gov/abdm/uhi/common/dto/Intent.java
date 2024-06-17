package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.Map;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class Intent {
    private Provider provider;

    private Item item;

    private Fulfillment fulfillment;

    private Category category;

    private Map<String, String> tags;

    private Chat chat;

    private Location location;
}
