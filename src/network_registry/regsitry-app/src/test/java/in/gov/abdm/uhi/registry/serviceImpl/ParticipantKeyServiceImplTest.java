package in.gov.abdm.uhi.registry.serviceImpl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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

import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.repository.ParticipantKeyRepository;

@ExtendWith(MockitoExtension.class)
class ParticipantKeyServiceImplTest {
	@Mock
	private ParticipantKeyRepository participantKeyRepository;

	@InjectMocks
	private ParticipantKeyServiceImpl participantKeyServiceImpl;

	@Autowired
	ObjectMapper mapper;

	/*
	 * @MockBean private CityServiceImpl cityServiceImpl;
	 * 
	 * @MockBean private DomainServiceImpl domainServiceImpl;
	 * 
	 * @MockBean private StatusServiceImpl serviceImpl;
	 */

	private List<ParticipantKey> listOfKey = null;
	// NetworkRoleDto networkRoleDto = null;
	// Domains d2 = null;
	ParticipantKey participantKey1 = null;
	ParticipantKey participantKey2 = null;
    private String keyRequestData="{\r\n"
		+ "    \"networkRoleId\":  1,\r\n"
		+ "    \"subscriberid\":\"nha.eua\",\r\n"
		+ "    \"uniqueKeyId\": \"nha.eua.k1\",\r\n"
		+ "    \"validFrom\": \"2023-12-29T07:06:28.309Z\",\r\n"
		+ "    \"validTo\": \"2024-12-30T18:30:00.000Z\"\r\n"
		+ "    \r\n"
		+ "}";
    private String keyResponseData="";
	@Test
	public void contextLoads() {
	}

	@BeforeEach
	public void loadData() throws JsonMappingException, JsonProcessingException {
		listOfKey = new ArrayList<ParticipantKey>();
		participantKey1 = new ParticipantKey(1, "nha.eua.k1", "publickeyzzz", "encryption key",
				"4090-01-11T14:49:29.000Z", "6089-01-19T01:49:29.000Z", null);
		participantKey2 = new ParticipantKey(2, "nha.eua.k2", "publickeyzzz", "encryption key",
				"2023-01-11T14:49:29.000Z", "2023-01-19T01:49:29.000Z", null);
		listOfKey.add(participantKey2);
		listOfKey.add(participantKey1);
	}

	@Test
	public void shouldGetAllParticipantKey() throws Exception {
		when(participantKeyRepository.findAll()).thenReturn(listOfKey);
		assertEquals(2, participantKeyServiceImpl.findAllParticipantKey().size());
	}
	

	@Test
	public void shouldGetParticipantKeyById() {
		int roleId = 1;
		when(participantKeyRepository.findById(roleId)).thenReturn(Optional.of(participantKey1));
		assertEquals(roleId, participantKeyServiceImpl.getOneParticipantKey(roleId).getId());
	}

	/*
	  @Test public void shouldSaveParticipantKey() { 
		  // given - precondition or setup //
	  NetworkParticipant participant = new NetworkParticipant(); //
	  participant.setParticipantId("nha");
	  when(participantKeyRepository.save(networkRole)).thenReturn(networkRole);
	  given(cityServiceImpl.findAllCity()).willReturn(); assertEquals(networkRole,
	  participantKeyServiceImpl.saveNetworkRole(networkRoleDto)); }
	 */

	@Test
	public void shouldDeleteParticipantKey() {
		// NetworkParticipant participant = new NetworkParticipant(1, "nha", null);
		when(participantKeyRepository.findById(1)).thenReturn(Optional.of(participantKey1));
		participantKeyServiceImpl.deleteParticipantKey(1);
		verify(participantKeyRepository, times(1)).delete(participantKey1);
	}

	// JUnit test for update employee REST API - positive scenario

	@Test
	public void shouldUpdateParticipantKey() {
		given(participantKeyRepository.save(participantKey1)).willReturn(participantKey1);
		when(participantKeyRepository.findById(1)).thenReturn(Optional.of(participantKey1));
		participantKey1.setUniqueKeyId("practo.eua.k1");
		ParticipantKey participantKeyData = participantKeyServiceImpl.updateParticipantKey(participantKey1);
		assertEquals(participantKey1.getUniqueKeyId(), participantKeyData .getUniqueKeyId());
	}

}
