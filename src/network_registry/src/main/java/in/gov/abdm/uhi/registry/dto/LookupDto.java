package in.gov.abdm.uhi.registry.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
@AllArgsConstructor
@NoArgsConstructor
@Data
public class LookupDto {
	public String status;
	public String type;
	public String domain;
	public String country;
	public String city;
}
