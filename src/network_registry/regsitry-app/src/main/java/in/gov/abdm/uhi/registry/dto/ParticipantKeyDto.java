package in.gov.abdm.uhi.registry.dto;

import java.io.Serializable;

import javax.persistence.Column;
import javax.validation.constraints.NotBlank;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ParticipantKeyDto implements Serializable {

	private static final long serialVersionUID = 1L;
	private Integer id;
	private Integer networkRoleId;
	private String subscriberid;
	@NotBlank(message ="Key id can't be blank!")
	private String uniqueKeyId;
	private String signingPublicKey;
	private String encrPublicKey;
	@NotBlank(message = "Valid from can't be blank!")
	private String validFrom;
	@NotBlank(message = "Valid to can't be blank!")
	private String validTo;

}
