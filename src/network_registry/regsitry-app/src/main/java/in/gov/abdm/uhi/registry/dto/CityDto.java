package in.gov.abdm.uhi.registry.dto;

import in.gov.abdm.uhi.registry.entity.State;
import lombok.Data;
@Data
public class CityDto {
		private Integer id;
		private String ldcaName;
		private String sdcaName;
		private String stdCode;
		private String description;
		private int stateId;
		//@ManyToOne
		//@JsonBackReference
		//private State state;
}
