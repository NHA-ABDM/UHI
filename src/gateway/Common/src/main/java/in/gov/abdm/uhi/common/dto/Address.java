package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Address {
	private String door;
	private String name;
	private String building;
	private String street;
	private String locality;
	private String ward;
	private String city;
	private String state;
	private String country;
	@JsonProperty(value = "area_code")
	private String areaCode;
}
