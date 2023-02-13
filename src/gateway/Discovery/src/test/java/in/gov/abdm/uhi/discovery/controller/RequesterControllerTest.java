package in.gov.abdm.uhi.discovery.controller;

import static org.mockito.Mockito.when;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.util.Assert;
import org.springframework.web.reactive.function.BodyInserters;
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
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.service.RequesterService;
import reactor.core.publisher.Mono;

@WebFluxTest(RequesterController.class)
public class RequesterControllerTest {

	@MockBean
	RequesterService requesterServiceMock;

	@MockBean
	SignatureUtility signatureUtility;

	@Autowired
	WebTestClient webTestClient;

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

	@BeforeEach
	public void setup() throws JsonProcessingException {
		populateHeaders();
	}

	@Test
	public void shouldReturnNackIfContextparamMissing() throws Exception {

		MessageAck messageAckTo = new MessageAck();
		Ack ack = new Ack();
		ack.setStatus("NACK");
		messageAckTo.setAck(ack);
		Mono<String> resp = Mono.just(mapper.writeValueAsString(messageAckTo));

		ctx.setAction("search");
		ctx.setDomain("nic2004:85111");
		// ctx.setCountry("IND"); // Any context value disable will make bad request
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

		when(requesterServiceMock.processor(stringRequest, headers)).thenReturn(resp);

		String jsonStringResponse = new String(
				webTestClient.post().uri("/api/v1/search").header(headersString).body(BodyInserters.fromValue(request))
						.exchange().expectStatus().isBadRequest().expectBody().returnResult().getResponseBody());
		Response response = mapper.readValue(jsonStringResponse, Response.class);
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("NACK"), "NACK");
	}

	@Test
	public void shouldReturnAck() throws Exception {

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

		MessageAck messageAckTo = new MessageAck();
		Ack ack = new Ack();
		ack.setStatus("ACK");
		messageAckTo.setAck(ack);
		response.setMessage(messageAckTo);

		Mono<String> resp = Mono.just(mapper.writeValueAsString(response));

		when(requesterServiceMock.processor(stringRequest, headers)).thenReturn(resp);

		webTestClient.post().uri("/api/v1/search").header(headersString).body(BodyInserters.fromValue(request))
				.exchange().expectStatus().is2xxSuccessful();

	}

	private void populateHeaders() {

		headers.put("Authorization", "");
		headersString = String.valueOf(headers);
		headersString = headersString.replaceAll("\\}", "");
	}
}
