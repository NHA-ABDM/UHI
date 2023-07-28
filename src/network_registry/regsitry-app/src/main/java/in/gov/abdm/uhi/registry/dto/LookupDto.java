package in.gov.abdm.uhi.registry.dto;


import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
@AllArgsConstructor
@NoArgsConstructor
@Data
public class LookupDto {
	@NotBlank(message = "Status should not be blank!")
	public String status;
	@NotBlank(message = "Domain should not be blank!")
	public String domain;
	@NotBlank(message = "Country should not be blank!")
	@Size(min = 3, max = 3,message = "Coutry should be first 3 digit!")
	public String country;
	@NotBlank(message = "City should not be blank!")
	public String city;
}
