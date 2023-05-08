package in.gov.abdm.uhi.registry.controller;

import static org.hamcrest.CoreMatchers.is;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.willDoNothing;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.NetworkRoleDto;
import in.gov.abdm.uhi.registry.dto.OperatingRegionDto;
import in.gov.abdm.uhi.registry.dto.ParticipantKeyDto;
import in.gov.abdm.uhi.registry.dto.StateDto;
import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.entity.State;
import in.gov.abdm.uhi.registry.serviceImpl.CityServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.NetworkParticipantServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.NetworkRoleServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.OperatingRegionServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.ParticipantKeyServiceImpl;
import in.gov.abdm.uhi.registry.serviceImpl.StateServiceImpl;

@SpringBootTest
@AutoConfigureMockMvc
class RegistryControllerTest {

	@MockBean
	private NetworkParticipantServiceImpl participantService;
	@MockBean
	private NetworkRoleServiceImpl networkRoleServiceImpl;
	@MockBean
	private OperatingRegionServiceImpl operatingRegionServiceImpl;
	@MockBean
	private ParticipantKeyServiceImpl participantKeyServiceImpl;
	@MockBean
	private CityServiceImpl cityServiceImpl;

	@MockBean
	private StateServiceImpl stateServiceImpl;
	// @Autowired
	private ObjectMapper mapper = new ObjectMapper();

	@Autowired
	private MockMvc mockMvc;
	private List<Cities> cityList = null;
	private List<State> stateList = null;
	private List<NetworkParticipant> participantList = null;
	NetworkParticipant participant1 = new NetworkParticipant();
	NetworkParticipant participant2 = new NetworkParticipant();
	NetworkRole networkRoleData = null;
	OperatingRegion operatingRegionData = null;
	NetworkRoleDto saveRoleData = null;
	OperatingRegionDto operatingRegionDto = null;
	ParticipantKey participantKeyData = null;
	ParticipantKeyDto participantKeyDto = null;
	private Object lookupResponseList = null;
	private LookupDto lookupDto = null;
	private Object searchReponseObject = null;
	String networkRolePayload = " {\r\n" + "        \"id\": 1,\r\n" + "        \"subscriberid\": \"practo-eua\",\r\n"
			+ "        \"type\": \"EUA\",\r\n"
			+ "        \"subscriberurl\": \"https://abha-uhipracto.practodev.com/v1/uhi\\n\",\r\n"
			+ "        \"domain\": {\r\n" + "            \"id\": 1,\r\n" + "            \"name\": \"Laboratories\",\r\n"
			+ "            \"code\": \"nic2008:86905\",\r\n"
			+ "            \"description\": \"Activities of independent diagonostic/pathological\"\r\n"
			+ "        },\r\n" + "        \"status\": {\r\n" + "            \"id\": 7,\r\n"
			+ "            \"name\": \"SUBSCRIBED\",\r\n" + "            \"description\": \"SUBSCRIBED\"\r\n"
			+ "        },\r\n" + "        \"operatingregion\": [\r\n" + "            {\r\n"
			+ "                \"id\": 3,\r\n" + "                \"city\": {\r\n"
			+ "                    \"id\": 3141,\r\n" + "                    \"state\": {\r\n"
			+ "                        \"id\": 3140,\r\n" + "                        \"name\": \"BOMBAY\",\r\n"
			+ "                        \"shortName\": \"BY\"\r\n" + "                    },\r\n"
			+ "                    \"ldca_name\": \"MUMBAI\",\r\n"
			+ "                    \"sdca_name\": \"MUMBAI\",\r\n" + "                    \"std_code\": \"std:022\"\r\n"
			+ "                },\r\n" + "                \"country\": \"IND\"\r\n" + "            },\r\n"
			+ "            {\r\n" + "                \"id\": 4,\r\n" + "                \"city\": {\r\n"
			+ "                    \"id\": 3490,\r\n" + "                    \"state\": {\r\n"
			+ "                        \"id\": 3488,\r\n" + "                        \"name\": \"KARNATAKA\",\r\n"
			+ "                        \"shortName\": \"KT\"\r\n" + "                    },\r\n"
			+ "                    \"ldca_name\": \"BANGALORE\",\r\n"
			+ "                    \"sdca_name\": \"ANEKAL\",\r\n"
			+ "                    \"std_code\": \"std:08110\"\r\n" + "                },\r\n"
			+ "                \"country\": \"IND\"\r\n" + "            }\r\n" + "        ],\r\n"
			+ "        \"participantKey\": {\r\n" + "            \"id\": 8,\r\n"
			+ "            \"uniqueKeyId\": \"pkb1039\",\r\n"
			+ "            \"signingPublicKey\": \"MFECAQEwBQYDK2VwBCIEIIn3kQALXeJrlZ+t3yBwNIzNag6TJvP/eO1DE5bocr+3gSEAi1SEbyUfnkbpfnj7ytFmj2BibnxqAPl2anQo1Cz2u8E=\",\r\n"
			+ "            \"encrPublicKey\": \"MCowBQYDK2VwAyEAi1SEbyUfnkbpfnj7ytFmj2BibnxqAPl2anQo1Cz2u8E=\",\r\n"
			+ "            \"validFrom\": \"2022-08-24T18:30:00.000Z\",\r\n"
			+ "            \"validTo\": \"2022-08-30T18:30:00.000Z\"\r\n" + "        }\r\n" + "    }";

	private String oprPayload = "{\r\n" + "        \"id\": 1,\r\n" + "        \"city\": {\r\n"
			+ "            \"id\": 3491,\r\n" + "            \"state\": {\r\n" + "                \"id\": 3488,\r\n"
			+ "                \"name\": \"KARNATAKA\",\r\n" + "                \"shortName\": \"KT\"\r\n"
			+ "            },\r\n" + "            \"ldca_name\": \"BANGALORE\",\r\n"
			+ "            \"sdca_name\": \"BANGALORE\",\r\n" + "            \"std_code\": \"std:080\"\r\n"
			+ "        },\r\n" + "        \"country\": \"IND\"\r\n" + "    }";

	private String keyPayload = "  {\r\n" + "        \"id\": 1,\r\n"
			+ "        \"uniqueKeyId\": \"driefcase_pubid\",\r\n"
			+ "        \"signingPublicKey\": \"MFECAQEwBQYDK2VwBCIEINYhoKj8CulXU0H1Y1tmaaZrEHbg2Bw3XFFoDBH4bXHIgSEAVTxVZ0J7pomgrvcOaYpz9dkeaaDjGReL1JY0f4FPg/8=\",\r\n"
			+ "        \"encrPublicKey\": \"MCowBQYDK2VwAyEAVTxVZ0J7pomgrvcOaYpz9dkeaaDjGReL1JY0f4FPg/8=\",\r\n"
			+ "        \"validFrom\": \"2022-08-24T18:30:00.000Z\",\r\n"
			+ "        \"validTo\": \"2022-08-30T18:30:00.000Z\"\r\n" + "    }";

	private String lookupPayload = "{\r\n" + "    \"message\": [\r\n" + "        {\r\n"
			+ "            \"subscriber_id\": \"nha.eua\",\r\n" + "            \"participant_id\": \"nha\",\r\n"
			+ "            \"country\": \"IND\",\r\n" + "            \"city\": \"std:01634\",\r\n"
			+ "            \"domain\": \"nic2008:86906\",\r\n"
			+ "            \"signing_public_key\": \"MFECAQEwBQYDK2VwBCIEIMDJ8pHpX20w188uFTgPHi6KessQOBfeDHiNztIo0KgWgSEAPVTyl9Jn0vD9Wyic+M+WL2XmkPMYc8mW1zxafAJSDRw=\",\r\n"
			+ "            \"encr_public_key\": \"MCowBQYDK2VwAyEAPVTyl9Jn0vD9Wyic+M+WL2XmkPMYc8mW1zxafAJSDRw=\",\r\n"
			+ "            \"valid_from\": \"2023-12-29T07:06:28.309Z\",\r\n"
			+ "            \"status\": \"INITIATED\",\r\n" + "            \"type\": \"eua\",\r\n"
			+ "            \"unique_key_id\": \"nha.eua.key2\",\r\n"
			+ "            \"valid_until\": \"2024-12-30T18:30:00.000Z\",\r\n"
			+ "            \"subscriber_url\": \"https://webhook.site/eua\"\r\n" + "        }\r\n" + "    ]\r\n" + "}";

	private String lookupRequest = "{\r\n" + "    \"status\":\"INITIATED\",\r\n"
			+ "    \"domain\":\"nic2008:86906\",\r\n" + "    \"country\": \"IND\",\r\n"
			+ "    \"city\": \"std:01634\"\r\n" + "    \r\n" + "}";
	private String searchRequest = "{\r\n" + "    \"subscriber_id\": \"nha.eua\",\r\n" + "    \"type\": \"EUA\",\r\n"
			+ "    \"domain\": \"nic2008:86906\",\r\n" + "    \"country\": \"IND\",\r\n"
			+ "    \"city\": \"std:01634\",\r\n" + "    \"unique_key_id\": \"nha.eua.key2\"\r\n" + "}";
	private String searchResponse = "[\r\n" + "    {\r\n" + "        \"subscriber_id\": \"nha.eua\",\r\n"
			+ "        \"participant_id\": \"nha\",\r\n" + "        \"country\": \"IND\",\r\n"
			+ "        \"city\": \"std:01634\",\r\n" + "        \"domain\": \"nic2008:86906\",\r\n"
			+ "        \"encr_public_key\": \"MCowBQYDK2VwAyEAPVTyl9Jn0vD9Wyic+M+WL2XmkPMYc8mW1zxafAJSDRw=\",\r\n"
			+ "        \"valid_from\": \"2023-12-29T07:06:28.309Z\",\r\n" + "        \"status\": \"INITIATED\",\r\n"
			+ "        \"type\": \"eua\",\r\n" + "        \"unique_key_id\": \"nha.eua.key2\",\r\n"
			+ "        \"valid_until\": \"2024-12-30T18:30:00.000Z\",\r\n"
			+ "        \"subscriber_url\": \"https://webhook.site/eua\"\r\n" + "    }\r\n" + "]";

	private String cityRequest = "[\r\n" + "    {\r\n" + "        \"state\": {\r\n"
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
		participant1.setId(1);
		participant1.setParticipantId("nha");
		participant1.setNetworkrole(null);
		participant2.setId(2);
		participant2.setParticipantId("practo");
		participant2.setNetworkrole(null);
		participantList = new ArrayList<>();
		participantList.add(participant1);
		participantList.add(participant2);
		networkRoleData = mapper.readValue(networkRolePayload, NetworkRole.class);
		saveRoleData = new NetworkRoleDto();
		saveRoleData.setNetworkParticipantId(participant1.getId());
		saveRoleData.setDomain("Ambulance");
		saveRoleData.setSubscriberUrl("https://www.eua.com");
		saveRoleData.setType("EUA");
		saveRoleData.setStatus("INITIATED");
		operatingRegionDto = new OperatingRegionDto();
		operatingRegionDto.setNetworkRoleId(2655);
		operatingRegionDto.setCity("ANDAMAN ISLANDS-std:03192");
		operatingRegionDto.setCountry("IND");
		operatingRegionData = mapper.readValue(oprPayload, OperatingRegion.class);
		participantKeyDto = mapper.readValue(keyPayload, ParticipantKeyDto.class);
		participantKeyData = mapper.readValue(keyPayload, ParticipantKey.class);
		lookupResponseList = mapper.readValue(lookupPayload, Object.class);
		lookupDto = mapper.readValue(lookupRequest, LookupDto.class);
		searchReponseObject = mapper.readValue(searchResponse, Object.class);
		cityList = mapper.readValue(cityRequest, new TypeReference<List<Cities>>() {
		});

		stateList = mapper.readValue(stateRequest, new TypeReference<List<State>>() {
		});

	}

	@Test
	public void shouldGetAllParticipant() throws Exception {
		// mapper.readValue(participantResponse,NetworkParticipant.class);
		// given - precondition or setup
		given(participantService.findAllNetworkParticipant()).willReturn(participantList);
		mockMvc.perform(get("/find-all-networkparticipant").accept(MediaType.APPLICATION_JSON))
				.andExpect(status().isOk()).andExpect(content().contentType(MediaType.APPLICATION_JSON)).andDo(print())
				.andExpect(jsonPath("$.size()", is(participantList.size())));

	}

	@Test
	public void shouldGetParticipantById() throws Exception {
		// given - precondition or setup
		int participantId = 1;
		given(participantService.getOneNetworkParticipant(participantId)).willReturn(participant1);
		ResultActions response = mockMvc.perform(get("/find-networkparticipant-by-id/{id}", participantId));
		// then - verify the output
		response.andDo(print()).andExpect(jsonPath("$.participantId", is(participant1.getParticipantId())));
	}

	@Test
	public void shouldSaveParticipant() throws JsonProcessingException, Exception {
		// given - precondition or setup
		given(participantService.saveNetworkParticipant(participant1)).willReturn(participant1);
		ResultActions response = mockMvc.perform(post("/save-networkparticipant")
				.contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(participant1)));
		// then - verify the result or output using assert statements
		response.andDo(print()).andExpect(status().isOk())
				.andExpect(jsonPath("$.participantId", is(participant1.getParticipantId())));
	}

	@Test
	public void shouldDeleteParticipant() throws Exception {
		// given - precondition or setup
		int participantId = 1;
		willDoNothing().given(participantService).deleteNetworkParticipant(participantId);
		// when - action or the behaviour that we are going test
		ResultActions response = mockMvc.perform(delete("/delete-network-participant-by-id/{id}", participantId));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print());
	}

	// JUnit test for update employee REST API - positive scenario
	@Test
	public void shouldUpdateNetworkParticipant() throws Exception {
		given(participantService.updateNetworkParticipant(participant1)).willReturn(participant1);
		participant1.setParticipantId("practo");
		ResultActions response = mockMvc.perform(put("/update-networkparticipant")
				.contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(participant1)));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print())
				.andExpect(jsonPath("$.participantId", is(participant1.getParticipantId())));
	}

// test case  for network role 

	@Test
	public void shouldGetNetworkroleById() throws Exception {
		networkRoleData = mapper.readValue(networkRolePayload, NetworkRole.class);
		// given - precondition or setup
		int roleId = 2655;
		given(networkRoleServiceImpl.getOneNetworkRole(roleId)).willReturn(networkRoleData);
		ResultActions response = mockMvc.perform(get("/find-networrole-by-id/{id}", roleId));
		// then - verify the output
		response.andDo(print()).andExpect(jsonPath("$.subscriberid", is(networkRoleData.getSubscriberid())));
	}

	@Test
	public void shouldDeleteNetworkrole() throws Exception {
		// given - precondition or setup
		int roleId = 1;
		willDoNothing().given(networkRoleServiceImpl).deleteNetworkRole(roleId);
		// when - action or the behaviour that we are going test
		ResultActions response = mockMvc.perform(delete("/delete-networkrole-by-id/{id}", roleId));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print());
	}

	@Test
	public void shouldSaveNetworkrole() throws JsonProcessingException, Exception {
		// given - precondition or setup
		given(networkRoleServiceImpl.saveNetworkRole(saveRoleData)).willReturn(networkRoleData);
		ResultActions response = mockMvc.perform(post("/save-networkrole").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(saveRoleData)));
		// then - verify the result or output using assert statements
		response.andDo(print()).andExpect(status().isOk())
				.andExpect(jsonPath("$.subscriberurl", is(networkRoleData.getSubscriberurl())));
	}

	@Test
	public void shouldUpdateNetworkrole() throws Exception {
		// NetworkRole updateData =
		// mapper.readValue(saveRoleData.toString(),NetworkRole.class);
		given(networkRoleServiceImpl.updateNetworkRole(networkRoleData)).willReturn(networkRoleData);
		networkRoleData.setSubscriberurl("http:www.hspa.com");
		ResultActions response = mockMvc.perform(put("/update-networkrole").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(networkRoleData)));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print())
				.andExpect(jsonPath("$.subscriberurl", is(networkRoleData.getSubscriberurl())));
	}

	// test case for operating region

	@Test
	public void shouldGetOperatingregionById() throws Exception {
		// given - precondition or setup
		int oprId = 2660;
		given(operatingRegionServiceImpl.getOneOperatingRegion(oprId)).willReturn(operatingRegionData);
		ResultActions response = mockMvc.perform(get("/find-operating-region-by-id/{id}", oprId));
		// then - verify the output
		response.andDo(print()).andExpect(jsonPath("$.country", is(operatingRegionData.getCountry())));
	}

	@Test
	public void shouldDeleteOperatingregion() throws Exception {
		// given - precondition or setup
		int oprId = 2660;
		willDoNothing().given(operatingRegionServiceImpl).deleteOperatingRegion(oprId);
		// when - action or the behaviour that we are going test
		ResultActions response = mockMvc.perform(delete("/delete-operating-region-by-id/{id}", oprId));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print());
	}

	@Test
	public void shouldSaveOperatingregion() throws JsonProcessingException, Exception {
		// int roleId =2655;
		// given - precondition or setup
		given(operatingRegionServiceImpl.saveOperatingRegion(operatingRegionDto)).willReturn(operatingRegionData);
		// given(networkRoleServiceImpl.getOneNetworkRole(roleId)).willReturn(networkRoleData);
		ResultActions response = mockMvc.perform(post("/save-operating-region").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(operatingRegionDto)));
		// then - verify the result or output using assert statements
		response.andDo(print()).andExpect(status().isOk())
				.andExpect(jsonPath("$.country", is(operatingRegionData.getCountry())));
	}

	@Test
	public void shouldUpdateOperatingregion() throws Exception {
		// NetworkRole updateData =
		// mapper.readValue(saveRoleData.toString(),NetworkRole.class);
		given(operatingRegionServiceImpl.updateOperatingRegion(operatingRegionData)).willReturn(operatingRegionData);
		operatingRegionData.setCountry("USA");
		ResultActions response = mockMvc.perform(put("/update-operating-region").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(operatingRegionData)));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print())
				.andExpect(jsonPath("$.country", is(operatingRegionData.getCountry())));
	}

	// test case for participant key

	@Test
	public void shouldGetParticipantkeyById() throws Exception {
		// given - precondition or setup
		int keyId = 2656;
		given(participantKeyServiceImpl.getOneParticipantKey(keyId)).willReturn(participantKeyData);
		ResultActions response = mockMvc.perform(get("/find-participant-key-by-id/{id}", keyId));
		// then - verify the output
		response.andDo(print()).andExpect(jsonPath("$.uniqueKeyId", is(participantKeyData.getUniqueKeyId())));
	}

	@Test
	public void shouldDeleteParticipantkey() throws Exception {
		// given - precondition or setup
		int keyId = 2656;
		willDoNothing().given(participantKeyServiceImpl).deleteParticipantKey(keyId);
		// when - action or the behaviour that we are going test
		ResultActions response = mockMvc.perform(delete("/delete-participant-key-by-id/{id}", keyId));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print());
	}

	@Test
	public void shouldSaveParticipantkey() throws JsonProcessingException, Exception {
		// int roleId =2655;
		// given - precondition or setup
		given(participantKeyServiceImpl.saveParticipantKey(participantKeyDto)).willReturn(participantKeyData);
		// given(networkRoleServiceImpl.getOneNetworkRole(roleId)).willReturn(networkRoleData);
		ResultActions response = mockMvc.perform(post("/save-participant-key").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(participantKeyDto)));
		// then - verify the result or output using assert statements
		response.andDo(print()).andExpect(status().isOk())
				.andExpect(jsonPath("$.uniqueKeyId", is(participantKeyData.getUniqueKeyId())));
	}

	@Test
	public void shouldUpdateParticipantkey() throws Exception {
		// NetworkRole updateData =
		// mapper.readValue(saveRoleData.toString(),NetworkRole.class);
		given(participantKeyServiceImpl.updateParticipantKey(participantKeyData)).willReturn(participantKeyData);
		participantKeyData.setUniqueKeyId("nha.eua.key3");
		;
		ResultActions response = mockMvc.perform(put("/update-participant-key").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(participantKeyData)));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print())
				.andExpect(jsonPath("$.uniqueKeyId", is(participantKeyData.getUniqueKeyId())));
	}

// test case for gateway looup

	@Test
	public void testGatewayLookup() throws Exception {
		// given - precondition or setup
		given(participantService.lookup(lookupDto)).willReturn(lookupResponseList);

		ResultActions response = mockMvc.perform(post("/lookup/gateway").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(lookupDto)));

		// then - verify the output
		response.andExpect(status().isOk()).andDo(print());

	}

	@Test
	public void testLookup() throws Exception {
		// given - precondition or setup
		given(participantService.search(searchRequest, null,true )).willReturn(searchReponseObject);
		ResultActions response = mockMvc.perform(post("/lookup").contentType(MediaType.APPLICATION_JSON)
				.content(mapper.writeValueAsString(searchReponseObject)));
		// then - verify the output
		response.andExpect(status().isOk()).andDo(print());

	}

	// test case for city

	@Test
	public void shouldSaveCities() throws Exception {

		// given((participantKeyDto)).willReturn(participantKeyData);
		given(cityServiceImpl.saveAllCity(cityList)).willReturn(cityList);
		ResultActions response = mockMvc.perform(
				post("/cities").contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(cityList)));
		// then - verify the result or output using assert statements
		response.andDo(print()).andExpect(status().isOk()).andExpect(jsonPath("$.size()", is(cityList.size())));

	}

	@Test
	public void shouldGetAllCities() throws Exception {
		given(cityServiceImpl.findAllCity()).willReturn(cityList);
		ResultActions response = mockMvc.perform(get("/cities"));
		// then - verify the output
		response.andDo(print()).andExpect(status().isOk()).andExpect(jsonPath("$.size()", is(cityList.size())));
	}

	// test case for state

	@Test
	public void shouldSaveState() throws JsonProcessingException, Exception {
		// given((participantKeyDto)).willReturn(participantKeyData);
		given(stateServiceImpl.saveAllState(stateList)).willReturn(stateList);
		ResultActions response = mockMvc.perform(
				post("/states").contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(stateList)));
		// then - verify the result or output using assert statements
		response.andDo(print()).andExpect(status().isOk()).andExpect(jsonPath("$.size()", is(stateList.size())));

	}

	@Test
	public void shouldGetAllState() throws Exception {
		List<StateDto> readValue = mapper.readValue(stateRequest, new TypeReference<List<StateDto>>() {
		});
		given(stateServiceImpl.findAllState()).willReturn(readValue);
		ResultActions response = mockMvc.perform(get("/states"));
		// then - verify the output
		response.andDo(print()).andExpect(status().isOk()).andExpect(jsonPath("$.size()", is(stateList.size())));

	}
}
