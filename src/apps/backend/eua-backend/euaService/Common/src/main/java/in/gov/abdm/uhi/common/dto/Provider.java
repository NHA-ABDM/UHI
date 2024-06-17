package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Set;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class Provider {
    private String id;
    private Descriptor descriptor;
    private Set<Category> categories;
    private List<Fulfillment> fulfillments;
    private List<Item> items;
    private Location location;
    private Contact contact;
}
