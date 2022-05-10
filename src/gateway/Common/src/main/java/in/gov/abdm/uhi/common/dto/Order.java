package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;

import lombok.Data;

@Data
public class Order {
	private Provider provider;
	private State state;
	private ArrayList<Items> items;
	private Billing billing;
	private Fulfillment fulfillment;
	private String email;
	private String phone;
	private Time time;
	private Quote quote;
}
