package in.gov.abdm.uhi.registry.entity;

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
@Entity
@AllArgsConstructor
@NoArgsConstructor
public class Subscriber implements Serializable {
	private static final long serialVersionUID = 1L;
	@JsonIgnore
	@Id
	@GeneratedValue(strategy=GenerationType.AUTO)
	private Integer id;
	
	@Column(name = "subscriber_id")
	@JsonProperty(value = "subscriber_id")
	private String subscriberId;

	@Column(name = "participant_id")
	@JsonIgnore
	private Integer participantId;

	/*
	 * @Column(name = "subscriber_id") private String subscriberId;
	 */

	private String country;

	private String city;
	private String domain;

	@Column(name = "unique_key_id")
	@JsonProperty(value = "unique_key_id")
	private String uniqueKeyId;

	@Column(name = "pubKeyId")
	@JsonProperty(value = "pub_key_id")
	private String pubKeyId;

	@Column(name = "signing_public_key")
	@JsonProperty(value = "signing_public_key")
	private String signingPublicKey;

	@Column(name = "encr_public_key")
	@JsonProperty(value = "encr_public_key")
	private String encrPublicKey;

	
	@Column(name = "valid_from")
	@JsonProperty(value = "valid_from")
	private String validFrom;

	
	@Column(name = "valid_to")
	@JsonProperty(value = "valid_to")
	private String validTo;

	private String status;

	@JsonIgnore
	private String createrUser;
	@JsonIgnore
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
	@JsonIgnore
	@Column(name = "challange_string")
	private String challangeString;

}
