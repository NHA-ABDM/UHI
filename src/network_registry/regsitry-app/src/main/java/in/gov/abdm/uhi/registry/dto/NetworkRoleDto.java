package in.gov.abdm.uhi.registry.dto;

import java.io.Serializable;
import java.util.List;

import javax.persistence.Column;
import javax.validation.constraints.NotBlank;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import in.gov.abdm.uhi.registry.entity.OperatingRegion;
import lombok.Data;

@Data

public class NetworkRoleDto implements Serializable {
	private static final long serialVersionUID = 1L;
	private Integer id;
	@Column(name = "netowrk_participant_id")
	private Integer networkParticipantId;
	@NotBlank(message = "Domain can't be blank!")
	@Column(name = "domain")
	private String domain;
	@NotBlank(message = "Type can't be blank!")
	@Column(name = "type")
	private String type;
	@NotBlank(message = "Subscriber url can't be blank!")
	@Column(name = "subscriber_url")
	private String subscriberUrl;
	@NotBlank(message = "Status url can't be blank!")
	@Column(name = "status")
	private String status;
	private List<OperatingRegion> operatingRegions;
}
