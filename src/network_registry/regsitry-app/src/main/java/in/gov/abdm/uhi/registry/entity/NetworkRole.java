package in.gov.abdm.uhi.registry.entity;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;
import lombok.EqualsAndHashCode;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Entity(name = "networkrole")
@Table(name = "network_role")
@Data
@EqualsAndHashCode(callSuper=true)
public class NetworkRole extends DateAudit {
	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer id;
	
	@Column(name = "subscriber_id")
	private String subscriberid;
	@Column(name = "type")
	private String type;
	
	@Column(name = "subscriber_url")
	private String subscriberurl;
	
	@OneToOne(cascade = { CascadeType.PERSIST, CascadeType.MERGE }, fetch = FetchType.LAZY)
	@JoinColumn(name = "domain_id", referencedColumnName = "id")
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	private Domains domain;
	
	@OneToOne(cascade = { CascadeType.PERSIST, CascadeType.MERGE }, fetch = FetchType.LAZY)
	@JoinColumn(referencedColumnName = "id",  name = "status_id")
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	private Status status;
	
	@OneToMany(cascade = { CascadeType.PERSIST, CascadeType.MERGE }, fetch = FetchType.LAZY)
	@JoinColumn(referencedColumnName = "id",  name = "network_role_id")
	private List<OperatingRegion> operatingregion;
	
	//@OneToMany(cascade = CascadeType.PERSIST, fetch = FetchType.LAZY)
	
//	@JoinColumn(referencedColumnName = "subscriber_id", name = "subscriber_id")
	/*@JoinColumns(value = {
	          @JoinColumn(name = "networkrole_id", referencedColumnName = "id"),
	          @JoinColumn(name = "subscriber_id", referencedColumnName = "subscriber_id") })*/
	// @JsonManagedReference
	 @JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	 @OneToOne(mappedBy = "networkrole",cascade =CascadeType.ALL,fetch = FetchType.LAZY)
	 ParticipantKey participantKey;
}
