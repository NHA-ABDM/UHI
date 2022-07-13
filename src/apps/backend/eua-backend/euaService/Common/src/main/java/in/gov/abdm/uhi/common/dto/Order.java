package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Order {
	private String id;
	private String ref_id;
	private Provider provider;
	//private State state;
	private String state;
	private Item item;
	private ArrayList<Item> items;
	private Fulfillment fulfillment;
	private Billing billing;
	private String email;
	private String phone;
	private Time time;
	private Quote quote;
	private Customer customer;
	private Payment payment;
}
