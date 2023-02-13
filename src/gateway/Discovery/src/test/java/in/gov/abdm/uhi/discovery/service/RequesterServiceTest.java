package in.gov.abdm.uhi.discovery.service;

import static org.mockito.Mockito.when;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.test.util.ReflectionTestUtils;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Agent;
import in.gov.abdm.uhi.common.dto.Category;
import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.Descriptor;
import in.gov.abdm.uhi.common.dto.Fulfillment;
import in.gov.abdm.uhi.common.dto.Intent;
import in.gov.abdm.uhi.common.dto.Item;
import in.gov.abdm.uhi.common.dto.Message;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.configuration.DiscoveryConfig;
import in.gov.abdm.uhi.discovery.security.Crypt;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import reactor.core.publisher.Mono;

@ExtendWith(MockitoExtension.class)
public class RequesterServiceTest {

	@InjectMocks
	RequesterService requesterServiceTest;

	@Mock
	NetworkRegistryService networkRegistryServiceMock;

	@Mock
	SignatureUtility signatureUtilityMock;

	@Mock
	Crypt cryptMock;

	@Mock
	HSPAService HSPAServiceMock;

	@Mock
	DiscoveryConfig discoveryConfigMock;

	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;

	@Value("${spring.application.gateway_pubKey}")
	String gateway_pubKey;

	@Value("${spring.application.gateway_privKey}")
	String gateway_privKey;

	Message msz = new Message();
	Context ctx = new Context();
	Request request = new Request();
	Category cat = new Category();
	Fulfillment ful = new Fulfillment();
	Item item = new Item();
	Descriptor desc = new Descriptor();
	Agent agent = new Agent();
	Intent intent = new Intent();
	Map<String, String> headers = new HashMap<String, String>();
	String headersString;
	String stringRequest;
	ObjectMapper mapper = new ObjectMapper();
	Response response = new Response();

	@Spy
	private final RequesterService springJunitService = new RequesterService();

	@BeforeEach
	void setUp() throws JsonProcessingException {
		populateSearch();
		populateHeaders();
		ReflectionTestUtils.setField(springJunitService, "isHeaderEnabled", "true");
		// lenient().when(networkRegistryServiceMock.circuitBreakerWrapper(request)).thenReturn(Mono.just(stringRequest));

	}

	public void shouldReturnAck() throws Exception {
		MessageAck messageAckTo = new MessageAck();
		Ack ack = new Ack();
		ack.setStatus("ACK");
		messageAckTo.setAck(ack);
		String subs = "{\"country\":\"IND\",\"city\":\"Pune\",\"domain\":\"Health\",\"status\":\"SUBSCRIBED\",\"radius\":null,\"type\":\"EUA\",\"url\":\"https://5dae-42-107-89-215.in.ngrok.io/callback\",\"subscriber_id\":\"harshad/HSPA\",\"unique_key_id\":\"UK436874\",\"pub_key_id\":\"PK52378428\",\"signing_public_key\":\"MFECAQEwBQYDK2VwBCIEIN0sOOEhim6B/Rim89QHmd0Je4+A06o49sCwphER0CaHgSEACw98eHapes0Vpsxb3IOop40BgfhuSTTz+GuGLwNLXxo=\",\"encr_public_key\":\"MCowBQYDK2VwAyEACw98eHapes0Vpsxb3IOop40BgfhuSTTz+GuGLwNLXxo=\",\"valid_from\":\"2022-07-14T18:30:00.000Z\",\"valid_to\":\"2022-07-20T18:30:00.000Z\"}";
		when(networkRegistryServiceMock.getParticipantsDetails(ctx, headers)).thenReturn(Mono.just(subs));
		when(networkRegistryServiceMock.validateParticipant(request, headers, stringRequest, subs))
				.thenReturn(Mono.just(subs));
		// when(networkRegistryServiceMock.circuitBreakerWrapper(request)).thenReturn(Mono.just(subs));

		System.out.println("stringRequest|" + stringRequest);
		Mockito.when(requesterServiceTest.processor(stringRequest, headers))
				.thenReturn(Mono.just(mapper.writeValueAsString(messageAckTo)));
		/*
		 * StepVerifier
		 * .create(requesterServiceTest.crypt.extractAuthorizationParams(headersString,
		 * headers)) .
		 */

	}

	private void populateHeaders() {

		headers.put("Authorization", "");
		headersString = String.valueOf(headers);
		headersString = headersString.replaceAll("\\}", "");
	}

	private void populateSearch() throws JsonProcessingException {

		ctx.setAction("search");
		ctx.setDomain("nic2004:85111");
		ctx.setCountry("IND");
		ctx.setCoreVersion("0.7.1");
		ctx.setCity("std:080");
		ctx.setConsumerId("eua-nha");
		ctx.setConsumerUri("http://uhieuasandbox.abdm.gov.in/api/v1/euaService");
		ctx.setMessageId(UUID.randomUUID() + "");
		ctx.setTimestamp(System.currentTimeMillis() + "");
		ctx.setTransactionId(UUID.randomUUID() + "");

		desc.setCode("CARDIOLOGY");
		desc.setName("CARDIOLOGY");
		cat.setDescriptor(desc);
		agent.setName("deepak");
		ful.setType("Online");
		ful.setAgent(agent);
		desc.setCode("Consultation");
		desc.setName("Consultation");
		item.setDescriptor(desc);
		intent.setCategory(cat);
		intent.setFulfillment(ful);
		intent.setItem(item);
		msz.setIntent(intent);
		request.setContext(ctx);
		request.setMessage(msz);

		stringRequest = mapper.writeValueAsString(request);
	}

}
