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

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.entity.State;
import in.gov.abdm.uhi.registry.repository.StateRepository;

@ExtendWith(MockitoExtension.class)
class StateServiceImplTest {

	@Mock
	private StateRepository stateRepository;

	@InjectMocks
	private StateServiceImpl stateServiceImpl;

	List<State> stateList = null;

	ObjectMapper mapper = new ObjectMapper();

	private String stateRequest = "[\r\n" + "    {\r\n" + "        \"name\": \"ANDAMAN & NICOBAR\",\r\n"
			+ "        \"shortName\": \"AN\"\r\n" + "    },\r\n" + "    {\r\n"
			+ "        \"name\": \"ANDHRA PRADESH\",\r\n" + "        \"shortName\": \"AP\"\r\n" + "    },\r\n"
			+ "    {\r\n" + "        \"name\": \"ASSAM\",\r\n" + "        \"shortName\": \"AS\"\r\n" + "    }]";

	@Test
	public void contextLoads() {
	}

	@BeforeEach
	public void loadData() throws JsonMappingException, JsonProcessingException {
		stateList = mapper.readValue(stateRequest, new TypeReference<List<State>>() {
		});
	}

	@Test
	public void shouldGetAllCity() throws Exception {
		when(stateRepository.findAll()).thenReturn(stateList);
		assertEquals(stateList.size(), stateServiceImpl.findAllState().size());
	}

	@Test
	public void shouldSaveCity() throws JsonMappingException, JsonProcessingException {
		when(stateRepository.saveAll(stateList)).thenReturn(stateList);
		assertEquals(stateList, stateServiceImpl.saveAllState(stateList));
	}

}
