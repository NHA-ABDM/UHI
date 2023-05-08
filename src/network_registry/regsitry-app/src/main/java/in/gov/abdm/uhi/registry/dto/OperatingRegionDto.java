package in.gov.abdm.uhi.registry.dto;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.validation.constraints.NotBlank;

import lombok.Data;

@Data
public class OperatingRegionDto implements Serializable {
	private static final long serialVersionUID = 1L;
	@Id
	@Column(name="id", nullable=false,unique =true)
	private Integer id;
	@Column(name = "network_role_id")
	private Integer networkRoleId;
	@NotBlank(message = "City can't be blank!")
	@Column(name = "city")
	private String  city;
	@NotBlank(message = "Country id can't be blank!")
	@Column(name = "country")
	private String country;
	@Column(name = "lat")
	private String lat;
	@Column(name = "lng")
	private String lng;
	@Column(name = "radious")
	private String radious;
	
}
