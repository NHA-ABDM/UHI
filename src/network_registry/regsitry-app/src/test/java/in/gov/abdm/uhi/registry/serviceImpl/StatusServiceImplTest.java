package in.gov.abdm.uhi.registry.serviceImpl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.entity.Status;
import in.gov.abdm.uhi.registry.repository.StatusRepository;

@ExtendWith(MockitoExtension.class)
class StatusServiceImplTest {
	@Mock
	private StatusRepository statusRepository;

	@InjectMocks
	private StatusServiceImpl statusServiceImpl;

	ObjectMapper mapper=new ObjectMapper() ;

	List<Status> readValue = null;
	ParticipantKey participantKey1 = null;
	ParticipantKey participantKey2 = null;
	String payload = "[\r\n" + "    {\r\n" + "        \"name\": \"Laboratories\",\r\n"
			+ "        \"code\": \"nic2008:86905\",\r\n"
			+ "        \"description\": \"Activities of independent diagonostic/pathological\"\r\n" + "    },\r\n"
			+ "    {\r\n" + "        \"name\": \"Blood banks\",\r\n" + "        \"code\": \"nic2008:86906\",\r\n"
			+ "        \"description\": \"Activities of independent blood banks\"\r\n" + "    },\r\n" + "    {\r\n"
			+ "        \"name\": \"Ambulance\",\r\n" + "        \"code\": \"nic2008:86909\",\r\n"
			+ "        \"description\": \"Other human health activities n.e.c (including independent ambulance activities)\"\r\n"
			+ "    },\r\n" + "    {\r\n" + "        \"name\": \"Pharmaceuticals\",\r\n"
			+ "        \"code\": \"nic2008:47721\",\r\n"
			+ "        \"description\": \"Retail sale of pharmaceutical, medical and orthopaedic goods and toilet articles\"\r\n"
			+ "    },\r\n" + "    {\r\n" + "        \"name\": \"Consultation services\",\r\n"
			+ "        \"code\": \"nic2008:86201\",\r\n"
			+ "        \"description\": \"Teleconsultation ,Medical practice activities\"\r\n" + "    }\r\n" + "]";

	@Test
	public void contextLoads() {
	}

	@BeforeEach
	public void loadData() throws JsonMappingException, JsonProcessingException {
		readValue = mapper.readValue(payload, new TypeReference<List<Status>>() {
		});

	}

	@Test
	public void shouldGetAllStatus() throws Exception {
		when(statusRepository.findAll()).thenReturn(readValue);
		assertEquals(readValue.size(), statusServiceImpl.findAllStatus().size());
	}

	@Test
	public void testSaveStatus() {
		// given - precondition or setup //
		when(statusRepository.saveAll(readValue)).thenReturn(readValue);
		assertEquals(readValue, statusServiceImpl.saveStatusList(readValue));
	}

}
