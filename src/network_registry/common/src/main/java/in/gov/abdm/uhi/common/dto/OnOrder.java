package in.gov.abdm.uhi.common.dto;

import java.util.ArrayList;

import lombok.Data;

@Data
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
