package in.gov.abdm.uhi.registry.entity;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Entity(name = "participantkey")
@Table(name = "participant_key")
@Data
@EqualsAndHashCode(callSuper=true)
@NoArgsConstructor
@AllArgsConstructor
public class ParticipantKey extends DateAudit {

	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	@Column(name = "id")
	private Integer id;
	@Column(name = "unique_key_id",unique = true)
	//@JsonProperty(value = "unique_key_id")
	private String uniqueKeyId;
	@Column(name = "signing_public_key")
	private String signingPublicKey;
	@Column(name = "encr_public_key")
	private String encrPublicKey;
	@Column(name = "valid_from")
	private String validFrom;
	@Column(name = "valid_to")
	private String validTo;
	@JsonIgnore
	 //@JsonBackReference
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	@OneToOne(cascade = { CascadeType.PERSIST, CascadeType.MERGE },fetch = FetchType.LAZY)
    @JoinColumn(name="networkrole_id",unique = true)
     NetworkRole networkrole;
	
}
