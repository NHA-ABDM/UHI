package in.gov.abdm.uhi.registry.controller;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import in.gov.abdm.uhi.registry.dto.CitiesDto;
import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.NetworkRoleDto;
import in.gov.abdm.uhi.registry.dto.OperatingRegionDto;
import in.gov.abdm.uhi.registry.dto.ParticipantKeyDto;
import in.gov.abdm.uhi.registry.dto.SearchDto;
import in.gov.abdm.uhi.registry.dto.StateDto;
import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.Domains;
import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.entity.State;
import in.gov.abdm.uhi.registry.entity.Status;
import in.gov.abdm.uhi.registry.repository.NetworkRoleRepository;
import in.gov.abdm.uhi.registry.serviceImpl.CityServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.DomainServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.NetworkParticipantServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.NetworkRoleServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.OperatingRegionServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.ParticipantKeyServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.StateServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.StatusServiceImpl;

@RestController
@CrossOrigin(origins = "*")
public class RegistryController {

	private static final Logger logger = LogManager.getLogger(NetworkRoleServiceImpl.class);
	@Autowired
	private NetworkParticipantServiceImpl networkParticipantService;

	@Autowired
	private NetworkRoleServiceImpl networkRoleService;

	@Autowired
	private OperatingRegionServiceImpl operatingRegionService;

	@Autowired
	private ParticipantKeyServiceImpl participantKeyService;

	@Autowired
	private CityServiceImpl cityServiceImpl;
	
	@Autowired
	NetworkRoleRepository networkRoleRepository;

	@Autowired
	private DomainServiceImpl domainServiceImpl;

	@Autowired
	private StatusServiceImpl statusServiceImpl;
	
	@Autowired
	private StateServiceImpl stateServiceImpl;
	
	LocalDate currentDate = LocalDate.now();
	DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
	
	/*public RegistryController(NetworkRoleRepository networkRoleRepository) {
		this.networkRoleRepository=networkRoleRepository;
		List<NetworkRole> networkroleData = networkRoleRepository.findAll();
		 List<NetworkRole> listData=null;
		if(!networkroleData.isEmpty()) { 
	      listData = networkroleData.stream().filter(data->(LocalDate.parse(data.getParticipantKey
		  ().getValidTo(), formatter).isBefore(currentDate.minusDays(1)))&&
		  data.getStatus().getName().equalsIgnoreCase("SUBSCRIBED")).collect(Collectors.toList());
		 // System.out.println("____________________"+listData.toString());
		  }
		//return listData;
	}*/
	
	
	
	

	@GetMapping("/find-all-networkparticipant")
	public List<NetworkParticipant> findAllNetworkParticipant() {
		logger.info("RegistryController ::findAllNetworkParticipant()");
		return networkParticipantService.findAllNetworkParticipant();
	}

	@PostMapping("/lookup/hspa")
	public ResponseEntity<Object> hspaLookup(@Validated @RequestBody LookupDto lookupDto) {
		logger.info("RegistryController ::hspaLookup()");
		return new ResponseEntity<>(networkParticipantService.lookup(lookupDto), HttpStatus.OK);
	}

	@PostMapping("/lookup")
	public ResponseEntity<Object> lookup(@Validated @RequestBody String searchDto,
			@RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, SignatureException, NoSuchProviderException, InvalidKeyException {
		logger.info("RegistryController ::lookup()");
		return new ResponseEntity<>(networkParticipantService.search(searchDto, headers, false), HttpStatus.OK);
	}

	@PostMapping("/lookup/internal")
	public ResponseEntity<Object> lookupInternal(@Validated @RequestBody String searchDto,
										 @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, SignatureException, NoSuchProviderException, InvalidKeyException {
		logger.info("RegistryController ::lookupInternal()");
		return new ResponseEntity<>(networkParticipantService.search(searchDto, headers, true), HttpStatus.OK);
	}
	
	
	@PostMapping("/search")
	public ResponseEntity<Object> search(@RequestBody SearchDto searchDto) {
		logger.info("RegistryController ::lookup()");
		return new ResponseEntity<>(networkParticipantService.GatewaySearch(searchDto), HttpStatus.OK);

	}

	@GetMapping("/cities")
	public List<Cities> findAllCity() {
		logger.info("RegistryController ::findAllCity()");
		return cityServiceImpl.findAllCity();
	}

	@GetMapping("/domains")
	public List<Domains> findAllDomain() {
		logger.info("RegistryController ::findAllDomain");
		return domainServiceImpl.findAllDomain();
	}
	
	@GetMapping("/states")
	public List<StateDto> findAllState() {
		logger.info("RegistryController ::findAllState");
		return stateServiceImpl.findAllState();
	}
	@PostMapping("/states")
	public ResponseEntity<List<State>> saveState(@RequestBody List<State> state) {
		logger.info("RegistryController ::saveState()");
		return new ResponseEntity<List<State>>(stateServiceImpl.saveAllState(state), HttpStatus.OK);
	}

	@PostMapping("/cities")
	public ResponseEntity<List<Cities>> saveCities(@RequestBody List<Cities> cities) {
		logger.info("RegistryController ::saveCities()");
		return new ResponseEntity<List<Cities>>(cityServiceImpl.saveAllCity(cities), HttpStatus.OK);
	}

	@PostMapping("/domains")
	public ResponseEntity<List<Domains>> saveDomains(@RequestBody List<Domains> domains) {
		logger.info("RegistryController ::saveDomains()");
		return new ResponseEntity<List<Domains>>(domainServiceImpl.saveAllDomain(domains), HttpStatus.OK);
	}

	@GetMapping("/find-networkparticipant-by-id/{id}")
	public NetworkParticipant findNetworkParticipantById(@PathVariable Integer id) {
		logger.info("RegistryController ::findNetworkParticipantById()");
		return networkParticipantService.getOneNetworkParticipant(id);
	}
	
	
	@GetMapping("/find-state-by-name/{name}")
	public  ResponseEntity<List<CitiesDto>> findCityByStateName(@PathVariable String name) {
		logger.info("RegistryController ::findNetworkParticipantById()");
		return new ResponseEntity<List<CitiesDto>>(cityServiceImpl.findByStateName(name.trim()), HttpStatus.OK);

	}
	

	@PostMapping("/save-networkparticipant")
	public NetworkParticipant saveNetworkParticipant(@Validated @RequestBody NetworkParticipant networkParticipant) {
		logger.info("RegistryController ::saveNetworkParticipant()");
		return networkParticipantService.saveNetworkParticipant(networkParticipant);
	}

	@DeleteMapping("/delete-network-participant-by-id/{id}")
	public String deleteNetworkParticipantById(@PathVariable Integer id) {
		logger.info("RegistryController ::deleteNetworkParticipantById()");
		networkParticipantService.deleteNetworkParticipant(id);
		return "Deleted id :" + id;
	}

	@GetMapping("/find-all-networkrole")
	public List<NetworkRole> findAllNetworkRole() {
		logger.info("RegistryController ::findAllNetworkRole()");
		return networkRoleService.findAllNetworkRole();
	}

	@GetMapping("/find-all-participantkey")
	public List<ParticipantKey> findAllPartcipantKey() {
		logger.info("RegistryController ::findAllPartcipantKey()");
		return participantKeyService.findAllParticipantKey();
	}
	
	@GetMapping("/find-all-operating-region")
	public List<OperatingRegion> findAllOperatingRegion() {
		logger.info("RegistryController ::findAllPartcipantKey()");
		return operatingRegionService.findAllOperatingRegion();
	}

	
	
	@PostMapping("/save-networkrole")
	public NetworkRole saveNetworkRole(@Validated @RequestBody NetworkRoleDto networkRole) {
		logger.info("RegistryController ::saveNetworkRole()");
		return networkRoleService.saveNetworkRole(networkRole);
	}

	@PostMapping("/save-operating-region")
	public OperatingRegion saveOperatingRegion(@Validated @RequestBody OperatingRegionDto operatingRegion) {
		logger.info("RegistryController ::saveOperatingRegion()");
		return operatingRegionService.saveOperatingRegion(operatingRegion);
	}

	@PostMapping("/save-participant-key")
	public ResponseEntity<ParticipantKey> saveParticipantKey(@Validated @RequestBody ParticipantKeyDto participantKey) throws NoSuchAlgorithmException {
		logger.info("RegistryController ::saveParticipantKey()");
		 ParticipantKey saveParticipantKey = participantKeyService.saveParticipantKey(participantKey);
		 return new ResponseEntity<ParticipantKey>(saveParticipantKey, HttpStatus.OK);
	}

	@DeleteMapping("/delete-networkrole-by-id/{id}")
	public String deleteNetworkRoleById(@PathVariable Integer id) {
		logger.info("RegistryController ::deleteNetworkRoleById()");
		networkRoleService.deleteNetworkRole(id);
		return "Deleted id :" + id;
	}

	@DeleteMapping("/delete-operating-region-by-id/{id}")
	public String deleteOperatingRegionById(@PathVariable Integer id) {
		logger.info("RegistryController ::deleteOperatingRegionById()");
		operatingRegionService.deleteOperatingRegion(id);
		return "Deleted id :" + id;
	}

	@DeleteMapping("/delete-participant-key-by-id/{id}")
	public String deleteParticipantKeyById(@PathVariable Integer id) {
		logger.info("RegistryController ::deleteParticipantKeyById()");
		participantKeyService.deleteParticipantKey(id);
		return "Deleted id :" + id;
	}

	@PostMapping("/save-status")
	public ResponseEntity<List<Status>> saveStatus(@RequestBody List<Status> status) {
		logger.info("RegistryController ::saveStatus()");
		return new ResponseEntity<List<Status>>(statusServiceImpl.saveStatusList(status), HttpStatus.OK);
	}

	@GetMapping("/status")
	public List<Status> findAllStatus() {
		logger.info("RegistryController ::findAllStatus");
		return statusServiceImpl.findAllStatus();
	}

	@PutMapping("/update-networkparticipant")
	ResponseEntity<NetworkParticipant> updateNetworkparticipant(@RequestBody NetworkParticipant networkparticipant) {
		logger.info("RegistryController ::updateNetworkparticipant()");
		return new ResponseEntity<NetworkParticipant>(
				networkParticipantService.updateNetworkParticipant(networkparticipant), HttpStatus.OK);
	}

	@PutMapping("/update-networkrole")
	public NetworkRole updateNetworkParticipant(@RequestBody NetworkRole networkParticipant) {
		logger.info("RegistryController ::updateNetworkParticipant()");
		return networkRoleService.updateNetworkRole(networkParticipant);
	}

	@PutMapping("/update-operating-region")
	ResponseEntity<OperatingRegion> updateOperatingRegion(@RequestBody OperatingRegion operatingRegion) {
		logger.info("RegistryController ::updateOperatingRegion()");
		return new ResponseEntity<OperatingRegion>(operatingRegionService.updateOperatingRegion(operatingRegion),
				HttpStatus.OK);
	}

	@PutMapping("/update-participant-key")
	ResponseEntity<ParticipantKey> updateParticipant(@RequestBody ParticipantKey participantKey) {
		logger.info("RegistryController ::updateParticipant()");
		return new ResponseEntity<ParticipantKey>(participantKeyService.updateParticipantKey(participantKey),
				HttpStatus.OK);
	}

	@GetMapping("/find-networrole-by-id/{id}")
	public NetworkRole findNetworkRoleById(@PathVariable Integer id) {
		logger.info("RegistryController ::findNetworkRoleById()");
		return networkRoleService.getOneNetworkRole(id);
	}

	@GetMapping("/find-operating-region-by-id/{id}")
	public OperatingRegion findOperatingRegionById(@PathVariable Integer id) {
		logger.info("RegistryController ::findOperatingRegionById()");
		return operatingRegionService.getOneOperatingRegion(id);
	}

	@GetMapping("/find-participant-key-by-id/{id}")
	public ParticipantKey findParticipantKeyById(@PathVariable Integer id) {
		return participantKeyService.getOneParticipantKey(id);
	}
	
	
}
