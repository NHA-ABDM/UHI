package in.gov.abdm.uhi.registry.entity;

import java.util.List;

import javax.persistence.*;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;
import lombok.EqualsAndHashCode;
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Entity(name="network_participant")
@Table(name = "network_participant")
@Data
@EqualsAndHashCode(callSuper=true)
public class NetworkParticipant extends DateAudit {
	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	@Column(name = "id", unique = true)
	private Integer id;
	@Column(name = "participant_id",unique = true)
	private String participantId;
	@Column(name = "participant_name",unique = true)
	private String participantName;
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	@OneToMany(cascade = CascadeType.ALL)
	@JoinColumn(referencedColumnName = "id", nullable = false, name = "participant_id")
	private List<NetworkRole> networkrole;
	
}
