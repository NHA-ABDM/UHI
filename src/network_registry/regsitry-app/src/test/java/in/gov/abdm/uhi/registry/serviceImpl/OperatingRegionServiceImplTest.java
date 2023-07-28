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
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.dto.OperatingRegionDto;
import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.Domains;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.entity.Status;
import in.gov.abdm.uhi.registry.repository.CitiesRepository;
import in.gov.abdm.uhi.registry.repository.NetworkRoleRepository;
import in.gov.abdm.uhi.registry.repository.OperatingRegionRepository;

@ExtendWith(MockitoExtension.class)
class OperatingRegionServiceImplTest {
	@Mock
	private OperatingRegionRepository operatingRegionRepository;

	@InjectMocks
	private OperatingRegionServiceImpl operatingRegionServiceImpl;

	@Mock
	private CitiesRepository citiesRepository;

	@InjectMocks
	private CityServiceImpl cityServiceImpl;

	@Mock
	private NetworkRoleRepository networkRoleRepository;

	@InjectMocks
	private NetworkRoleServiceImpl networkRoleService;

	// @Autowired
	ObjectMapper mapper = new ObjectMapper();


	/*
	 ** 
	 * @MockBean private DomainServiceImpl domainServiceImpl;
	 * 
	 * @MockBean private StatusServiceImpl serviceImpl;
	 */

	private List<OperatingRegion> listofOperatingRegion = null;
	OperatingRegion saveOperatingRegion = null;
	OperatingRegionDto operatingRegionDto = null;
	Domains d2 = null;
	OperatingRegion opr1 = null;
	OperatingRegion opr3=null;
	OperatingRegion opr2 = null;
	Cities city2 = null;
	Cities city3 = null;
	Cities updateCity = null;
	List<Cities> cityList = null;
	NetworkRole networkRole1 = null;
	Cities city1 = null;
	String oprRequestDto = "{\r\n" + "    \"networkRoleId\": 1,\r\n" + "    \"country\": \"IND\",\r\n"
			+ "    \"city\":\"YELLAREDDY-std:08465\"\r\n" + "}\r\n" + "";

	@Test
	public void contextLoads() {
	}

	@BeforeEach
	public void loadData() throws JsonMappingException, JsonProcessingException {
		listofOperatingRegion = new ArrayList<OperatingRegion>();
		networkRole1 = new NetworkRole();

		cityList = new ArrayList<Cities>();
		opr1 = new OperatingRegion();
		opr2 = new OperatingRegion();
		networkRole1.setOperatingregion(listofOperatingRegion);
		city1 = new Cities();
		city2 = new Cities();
		city1.setId(1);
		city1.setLdcaName("ANDAMAN & NICOBAR");
		city1.setSdcaName("ANDAMAN ISLANDS-std:03192");
		city1.setStdCode("std:3192");
		city2.setId(2);
		city2.setLdcaName("ADILABAD");
		city2.setSdcaName("ADILABAD");
		city2.setStdCode("std:08732");

		city3 = new Cities();
		city3.setId(10);
		city3.setLdcaName("YELLAREDDY");
		city3.setSdcaName("YELLAREDDY-std:08465");
		city3.setStdCode("std:08465");
		city3.setId(2);

		opr1.setId(1);
		opr1.setCountry("IND");
		opr1.setCity(city1);
		opr1.setCreatedAt(java.time.LocalDateTime.now());
		opr1.setUpdatedAt(java.time.LocalDateTime.now());
		opr2.setId(2);
		opr2.setCountry("IND");
		opr2.setCity(city2);
		opr2.setCreatedAt(java.time.LocalDateTime.now());
		opr2.setUpdatedAt(java.time.LocalDateTime.now());
		listofOperatingRegion.add(opr1);
		listofOperatingRegion.add(opr2);
		cityList.add(city1);
		cityList.add(city2);
       opr3=new OperatingRegion();
       opr3.setCity(city3);
       opr3.setCountry("IND");
		// operatingRegion.setCreatedAt(null);
		Domains d1 = new Domains();
		d1.setId(1);
		d1.setName("Ambulance");
		d1.setCode("nic2008:86909");
		d1.setDescription("AMB");
		Status st = new Status();
		st.setId(1);
		st.setName("INITIATED");
		st.setDescription("INIT");
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
		updateCity = new Cities();
		// networkRole1.setOperatingregion(listofOperatingRegion);
		updateCity.setSdcaName("ANDAMAN ISLANDS-std:03192");

		operatingRegionDto = mapper.readValue(oprRequestDto, OperatingRegionDto.class);
		// saveOperatingRegion=mapper.readValue(oprRequestDto,OperatingRegion.class);

	}

	@Test
	public void shouldGetAllOperatingRegion() throws Exception {
		when(operatingRegionRepository.findAll()).thenReturn(listofOperatingRegion);
		assertEquals(2, operatingRegionServiceImpl.findAllOperatingRegion().size());
	}

	@Test
	public void shouldGetOperatingRegionById() {
		int oprId = 1;
		when(operatingRegionRepository.findById(oprId)).thenReturn(Optional.of(opr1));
		assertEquals(oprId, operatingRegionServiceImpl.getOneOperatingRegion(oprId).getId());
	}

	@Test
	public void testSaveOperatingRegion() throws JsonMappingException, JsonProcessingException {
		when(networkRoleRepository.findById(1)).thenReturn(Optional.of(networkRole1));
		given(citiesRepository.findBySdcaNameIgnoreCaseAndStdCode("YELLAREDDY", "std:08465")).willReturn(city3);
		networkRole1.setOperatingregion(listofOperatingRegion);
		assertEquals(opr3, operatingRegionServiceImpl.saveOperatingRegion(operatingRegionDto));

	}

	@Test
	public void shouldDeleteOperatingRegion() {
		when(operatingRegionRepository.findById(1)).thenReturn(Optional.of(opr1));
		operatingRegionServiceImpl.deleteOperatingRegion(1);
		verify(operatingRegionRepository, times(1)).deleteById(1);
	}

	// JUnit test for update employee REST API - positive scenario

	@Test
	public void shouldUpdateOperatingRegion() {
		given(operatingRegionRepository.save(opr1)).willReturn(opr1);
		given(citiesRepository.findBySdcaNameIgnoreCaseAndStdCode("ANDAMAN ISLANDS", "std:03192")).willReturn(city1);
		when(operatingRegionRepository.findById(1)).thenReturn(Optional.of(opr1));
		opr1.setCity(updateCity);
		OperatingRegion updateOpr = operatingRegionServiceImpl.updateOperatingRegion(opr1);
		assertEquals(opr1.getCity().getLdcaName(), updateOpr.getCity().getLdcaName());
	}

}
