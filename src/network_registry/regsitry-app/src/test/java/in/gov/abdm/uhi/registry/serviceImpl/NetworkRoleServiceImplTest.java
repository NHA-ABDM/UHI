package in.gov.abdm.uhi.registry.serviceImpl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.BDDMockito.given;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.dto.NetworkRoleDto;
import in.gov.abdm.uhi.registry.dto.OperatingRegionDto;
import in.gov.abdm.uhi.registry.entity.Domains;
import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.entity.Status;
import in.gov.abdm.uhi.registry.repository.CitiesRepository;
import in.gov.abdm.uhi.registry.repository.DomainRepository;
import in.gov.abdm.uhi.registry.repository.NetworkParticipantRepository;
import in.gov.abdm.uhi.registry.repository.NetworkRoleRepository;
import in.gov.abdm.uhi.registry.repository.StatusRepository;

@ExtendWith(MockitoExtension.class)
class NetworkRoleServiceImplTest {
	@Mock
	private NetworkRoleRepository networkRoleRepository;
	@InjectMocks
	private DomainServiceImpl domainServiceImpl;
	@InjectMocks
	private CityServiceImpl cityServiceImpl;
	@InjectMocks
	private StatusServiceImpl serviceImpl;
	@InjectMocks
	private NetworkRoleServiceImpl networkRoleService;
	@Mock
	private DomainRepository domainRepository;
	@Mock
	private StatusRepository statusRepository;
	@Mock
	private NetworkParticipantRepository networkParticipantRepository;
	
	
	//@Mock
	//private CitiesRepository citiesRepository;

	ObjectMapper mapper = new ObjectMapper();

	/*
	 * @MockBean private CityServiceImpl cityServiceImpl;
	 * 
	 * @MockBean private DomainServiceImpl domainServiceImpl;
	 * 
	 * @MockBean private StatusServiceImpl serviceImpl;
	 */

	private List<NetworkRole> listofNetworkrole = null;
	NetworkRoleDto networkRoleDto = null;
	Domains d2 = null;
	Domains d1 = null;
	Domains d3 = null;
	NetworkRole networkRole1 = null;
	NetworkRole networkRole2 = null;
	NetworkParticipant participant=null;
	Status st = null;
	private String networkRolePayload="{\r\n"
			+ "    \"networkParticipantId\":1,\r\n"
			+ "    \"domain\":\"Laboratories\",\r\n"
			+ "    \"type\": \"eua\",\r\n"
			+ "    \"status\": \"INITIATED\",\r\n"
			+ "    \"subscriberUrl\": \"https://webhook.site/eua\"\r\n"
			+ "}";
	
	private String responseData="{\r\n"
			+ "    \"subscriberid\": \"nha.eua\",\r\n"
			+ "    \"type\": \"eua\",\r\n"
			+ "    \"subscriberurl\": \"https://webhook.site/eua\",\r\n"
			+ "    \"domain\": {\r\n"
			+ "        \"id\":10,\r\n"
			+ "        \"name\": \"Laboratories\",\r\n"
			+ "        \"code\": \"nic2008:86905\",\r\n"
			+ "        \"description\": \"Activities of independent diagonostic/pathological\"\r\n"
			+ "    },\r\n"
			+ "    \"status\": {\r\n"
			+ "        \"id\":1,\r\n"
			+ "        \"name\": \"INITIATED\",\r\n"
			+ "        \"description\": \"INITIATED\"\r\n"
			+ "    }\r\n"
			+ "}";

	@Test
	public void contextLoads() {
	}

	@BeforeEach
	public void loadData() throws JsonMappingException, JsonProcessingException {
		listofNetworkrole = new ArrayList<NetworkRole>();
		d1 = new Domains();
		d1.setId(1);
		d1.setName("Ambulance");
		d1.setCode("nic2008:86909");
		d1.setDescription("AMB");
		d2 = new Domains();
		d2.setId(2);
		d2.setName("Blood Banks");
		d2.setCode("nic2008:86906");
		d2.setDescription("BLD");
		
		d3 = new Domains();
		d3.setId(10);
		d3.setName("Laboratories");
		d3.setCode("nic2008:86905");
		d3.setDescription("Activities of independent diagonostic/pathological");
		st = new Status();
		st.setId(1);
		st.setName("INITIATED");
		st.setDescription("INITIATED");
		// networkRoleDto = new NetworkRoleDto(1, 1, "EUA", "https://www.eua.com",
		// "Ambulance", "INITIATED", null);
		ParticipantKey key = new ParticipantKey(1, "keyid", "publickeyzzz", "encryption key",
				"2023-01-11T14:49:29.000Z", "2023-01-19T01:49:29.000Z", null);
		networkRole1 = new NetworkRole();
		networkRole1.setId(1);
		networkRole1.setSubscriberid("nha.eua");
		networkRole1.setType("EUA");
		networkRole1.setSubscriberurl("https://www.eua.com");
		networkRole1.setDomain(d1);
		networkRole1.setStatus(st);
		networkRole1.setParticipantKey(key);

		networkRole2 = new NetworkRole();
		networkRole2.setId(1);
		networkRole2.setSubscriberid("nha.eua");
		networkRole2.setType("EUA");
		networkRole2.setSubscriberurl("https://www.eua.com");
		networkRole2.setDomain(d1);
		networkRole2.setStatus(st);
		networkRole2.setParticipantKey(key);
		// role1 = new NetworkRole(1, "nha.eua", "EUA", "https://www.eua.com", d1, st,
		// null, key);

		// NetworkRole role2 = new NetworkRole(2, "nha.eua", "EUA",
		// "https://www.eua.com", d2, st, null, key);
		listofNetworkrole.add(networkRole1);
		listofNetworkrole.add(networkRole2);

		// networkRoleDto =mapper.readValue(payload,NetworkRoleDto.class);
		participant=new NetworkParticipant();
		participant.setId(1);
		participant.setParticipantId("nha");
	}

	@Test
	public void shouldGetAllNetworkRole() throws Exception {
		when(networkRoleRepository.findAll()).thenReturn(listofNetworkrole);
		assertEquals(2, networkRoleService.findAllNetworkRole().size());
	}

	@Test
	public void shouldGetNetworkRoleById() {
		int roleId = 1;
		when(networkRoleRepository.findById(roleId)).thenReturn(Optional.of(networkRole1));
		assertEquals(roleId, networkRoleService.getOneNetworkRole(roleId).getId());
	}

	@Test
	public void testSaveNetworkRole() throws JsonMappingException, JsonProcessingException { // given - precondition or setup //
		networkRoleDto=	 mapper.readValue(networkRolePayload,NetworkRoleDto.class);
		NetworkRole networkRole = mapper.readValue(responseData,NetworkRole.class);
		when(networkParticipantRepository.findById(1)).thenReturn(Optional.of(participant));
		given(domainRepository.findByNameIgnoreCase("Laboratories")).willReturn(d3);
		when(statusRepository.findByNameIgnoreCase(st.getName())).thenReturn((st));
		//networkRole1.set
		participant.setNetworkrole(listofNetworkrole);
		assertEquals(networkRole, networkRoleService.saveNetworkRole(networkRoleDto));

	}

	@Test
	public void shouldDeleteNetworkRole() {
		// NetworkParticipant participant = new NetworkParticipant(1, "nha", null);
		when(networkRoleRepository.findById(1)).thenReturn(Optional.of(networkRole1));
		networkRoleService.deleteNetworkRole(1);
		verify(networkRoleRepository, times(1)).deleteById(1);
	}

	// JUnit test for update employee REST API - positive scenario

	@Test
	public void shouldUpdateNetworkRole() {
		// domainServiceImpl

		given(networkRoleRepository.save(networkRole1)).willReturn(networkRole1);
		when(networkRoleRepository.findById(1)).thenReturn(Optional.of(networkRole1));
		networkRole1.setSubscriberurl("https:www.hspa.com");
		when(domainRepository.findByNameIgnoreCase(d1.getName())).thenReturn((d1));
		when(statusRepository.findByNameIgnoreCase(st.getName())).thenReturn((st));
		NetworkRole updateNetworkRole = networkRoleService.updateNetworkRole(networkRole1);
		assertEquals(networkRole1.getSubscriberurl(), updateNetworkRole.getSubscriberurl());
	}

}
