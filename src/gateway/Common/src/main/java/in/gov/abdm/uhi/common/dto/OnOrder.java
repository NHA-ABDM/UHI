package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.ArrayList;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class OnOrder {
    private String id;
    private String state;
    private Provider provider;
    private ArrayList<Items> items;
    private Billing billing;
    private Fulfillment fulfillment;
    private Quote quote;
    private Payment payment;
}
