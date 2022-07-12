package in.gov.abdm.uhi.registry.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.validation.constraints.Past;

import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Before;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Data
public class SubscriberDto {
	
	private Integer id;
	@JsonProperty(value = "subscriber_id")
	private String subscriberId;

	// @JsonIgnore
	private Integer participantId;

	private String country;

	private String city;
	private String domain;

	@JsonProperty(value = "unique_key_id")
	private String uniqueKeyId;

	@JsonProperty(value = "pub_key_id")
	private String pubKeyId;

	@JsonProperty(value = "signing_public_key")
	private String signingPublicKey;

	@JsonProperty(value = "encr_public_key")
	private String encrPublicKey;

	@JsonProperty(value = "valid_from")
	private String validFrom;

	@JsonProperty(value = "valid_to")
	private String validTo;

	private String status;

	// @JsonIgnore
	private String createrUser;
	// @JsonIgnore
	private String updaterUser;

	private String radius;
	@Column(name = "sub_type")
	private String type;

	private String url;

	@JsonIgnore
	@CreationTimestamp
	private LocalDateTime createDateTime;

	@JsonIgnore
	@UpdateTimestamp
	private LocalDateTime updateDateTime;
	private String challangeString;

}
