package in.gov.abdm.uhi.common.dto;

import lombok.Data;

@Data
public class Customer {
	private String id;
	private String cred;
	private Person person;
	private Contact contact;
}
