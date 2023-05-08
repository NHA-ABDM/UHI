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

import com.fasterxml.jackson.core.JsonProcessingException;

import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
import in.gov.abdm.uhi.registry.repository.NetworkParticipantRepository;
import in.gov.abdm.uhi.registry.service.NetworkParticipantService;

@ExtendWith(MockitoExtension.class)
class NetworkParticipantServiceImplTest {
	@Mock
	private NetworkParticipantRepository networkParticipantRepository;

	@InjectMocks
	private NetworkParticipantServiceImpl participantService;
	//NetworkParticipant participant = new NetworkParticipant(1, "nha", null);
	NetworkParticipant participant1 = new NetworkParticipant();
	NetworkParticipant participant2 = new NetworkParticipant();
	private List<NetworkParticipant> participantList = null;
	
	@BeforeEach
	public void contextLoads() {
		participant1.setId(1);
		participant1.setParticipantId("nha");
		participant1.setNetworkrole(null);
		participant2.setId(2);
		participant2.setParticipantId("practo");
		participant2.setNetworkrole(null);
		participantList = new ArrayList<>();
		participantList.add(participant1);
		participantList.add(participant2);
	}

	@Test
	public void shouldGetAllParticipant() throws Exception {
		when(networkParticipantRepository.findAll())
				.thenReturn(participantList);
		assertEquals(2, participantService.findAllNetworkParticipant().size());
	}

	@Test
	public void shouldGetParticipantById() throws Exception {
		int employeeId = 1;
		
		when(networkParticipantRepository.findById(employeeId)).thenReturn(Optional.of(participant1));
		assertEquals(participant1.getParticipantId(), participantService.getOneNetworkParticipant(employeeId).getParticipantId());
	}

	@Test
	public void shouldSaveParticipant() throws JsonProcessingException, Exception {
		// given - precondition or setup
		NetworkParticipant participant = new NetworkParticipant();
		participant.setParticipantId("nha");
		when(networkParticipantRepository.save(participant)).thenReturn(participant);
		assertEquals(participant, participantService.saveNetworkParticipant(participant));
	}

	@Test
	public void shouldDeleteParticipant() throws Exception {
		when(networkParticipantRepository.findById(1)).thenReturn(Optional.of(participant1));
		participantService.deleteNetworkParticipant(1);
		verify(networkParticipantRepository, times(1)).deleteById(participant1.getId());
	}

	// JUnit test for update employee REST API - positive scenario
	@Test
	public void shouldUpdateNetworkParticipant() throws Exception {
		given(networkParticipantRepository.save(participant1)).willReturn(participant1);
		when(networkParticipantRepository.findById(1)).thenReturn(Optional.of(participant1));
		participant1.setParticipantId("practo");
		NetworkParticipant updateNetworkParticipant = participantService.updateNetworkParticipant(participant1);
		assertEquals(participant1.getParticipantId(), updateNetworkParticipant.getParticipantId());
	}

}
