package in.gov.abdm.uhi.registry.entity;


import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.EqualsAndHashCode;
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Entity
@Table(name = "city")
@Data
@EqualsAndHashCode(callSuper=true)
public class Cities extends DateAudit{
	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	@Column(name="id", nullable=false,unique =true)
	private Integer id;
	@JsonProperty(value = "ldca_name")
	@Column(name = "ldca_name")
	private String ldcaName;
	@JsonProperty(value = "sdca_name")
	@Column(name = "sdca_name")
	private String sdcaName;
	@JsonProperty(value = "std_code")
	@Column(name = "std_code",unique =true)
	private String stdCode;
	@Column(name = "description")
	private String description;
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	@ManyToOne(cascade = { CascadeType.PERSIST, CascadeType.MERGE }, fetch = FetchType.LAZY)
	private State state;

}
