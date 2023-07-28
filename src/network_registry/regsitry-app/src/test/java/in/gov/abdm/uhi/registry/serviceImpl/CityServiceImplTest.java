package in.gov.abdm.uhi.registry.serviceImpl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

import java.util.List;

import javax.persistence.EntityManager;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.entity.State;
import in.gov.abdm.uhi.registry.repository.CitiesRepository;
import in.gov.abdm.uhi.registry.repository.StateRepository;

@ExtendWith(MockitoExtension.class)
class CityServiceImplTest {
	@Mock
	private CitiesRepository citiesRepository;
	@Mock
	private StateRepository stateRepository;
	
	@Mock
	EntityManager entityManager;

	@InjectMocks
	private CityServiceImpl cityServiceImpl;

	
	
	ObjectMapper mapper=new ObjectMapper();

	List<Cities> readValue = null;
	ParticipantKey participantKey1 = null;
	ParticipantKey participantKey2 = null;
	String payload ="[\r\n" + "    {\r\n" + "        \"state\": {\r\n"
			+ "            \"name\": \"ANDAMAN & NICOBAR\"\r\n" + "        },\r\n"
			+ "        \"ldca_name\": \"ANDAMAN & NICOBAR\",\r\n" + "        \"sdca_name\": \"ANDAMAN ISLANDS\",\r\n"
			+ "        \"std_code\": \"std:03192\"\r\n" + "    },\r\n" + "    {\r\n" + "        \"state\": {\r\n"
			+ "            \"name\": \"ANDAMAN & NICOBAR\"\r\n" + "        },\r\n"
			+ "        \"ldca_name\": \"ANDAMAN & NICOBAR\",\r\n" + "        \"sdca_name\": \"NICOBAR ISLANDS\",\r\n"
			+ "        \"std_code\": \"std:03193\"\r\n" + "    }]";
	private String stateRequest = "[\r\n" + "    {\r\n" + "        \"name\": \"ANDAMAN & NICOBAR\",\r\n"
			+ "        \"shortName\": \"AN\"\r\n" + "    },\r\n" + "    {\r\n"
			+ "        \"name\": \"ANDHRA PRADESH\",\r\n" + "        \"shortName\": \"AP\"\r\n" + "    },\r\n"
			+ "    {\r\n" + "        \"name\": \"ASSAM\",\r\n" + "        \"shortName\": \"AS\"\r\n" + "    }]";

	
    @Test
	public void contextLoads() {
	}

	@BeforeEach
	public void loadData() throws JsonMappingException, JsonProcessingException {
		readValue = mapper.readValue(payload, new TypeReference<List<Cities>>() {
		});
		
	}

	@Test
	public void shouldGetAllCity() throws Exception {
		when(citiesRepository.findAll()).thenReturn(readValue);
		assertEquals(readValue.size(), cityServiceImpl.findAllCity().size());
	}

	@Test
	public void shouldSaveCity() throws JsonMappingException, JsonProcessingException {
		List<State> stateList = mapper.readValue(stateRequest, new TypeReference<List<State>>() {
		});
		State state = stateList.get(0);
		// given - precondition or setup //
	//	when(readValue.get(0).getState().getName()).thenReturn(stateList.get(0).getName());
		
		when(citiesRepository.saveAll(readValue)).thenReturn(readValue);
		when(stateRepository.findAll()).thenReturn(stateList);
		when(entityManager.getReference(State.class, state.getId())).thenReturn(state);
		assertEquals(readValue, cityServiceImpl.saveAllCity(readValue));
	}

}
