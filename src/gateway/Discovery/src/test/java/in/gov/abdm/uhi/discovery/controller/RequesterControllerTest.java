//package in.gov.abdm.uhi.discovery.controller;
//
//import com.fasterxml.jackson.core.JsonProcessingException;
//import com.fasterxml.jackson.databind.ObjectMapper;
//import in.gov.abdm.uhi.common.dto.*;
//<<<<<<< HEAD
//import in.gov.abdm.uhi.discovery.security.SignatureUtility;
//=======
//>>>>>>> patch_headers
//import in.gov.abdm.uhi.discovery.service.RequesterService;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
//import org.springframework.boot.test.mock.mockito.MockBean;
//import org.springframework.test.web.reactive.server.WebTestClient;
//import org.springframework.util.Assert;
//import org.springframework.web.reactive.function.BodyInserters;
//import reactor.core.publisher.Mono;
//
//import java.util.HashMap;
//import java.util.Map;
//import java.util.UUID;
//
//import static org.mockito.Mockito.when;
//
//@WebFluxTest(RequesterController.class)
// class RequesterControllerTest {
//
//    @MockBean
//    RequesterService requesterServiceMock;
//
//<<<<<<< HEAD
//    @MockBean
//    SignatureUtility signatureUtility;
//=======
//>>>>>>> patch_headers
//
//    @Autowired
//    WebTestClient webTestClient;
//
//    Message msz = new Message();
//    Context ctx = new Context();
//    Request request = new Request();
//    Category cat = new Category();
//    Fulfillment ful = new Fulfillment();
//    Item item = new Item();
//    Descriptor desc = new Descriptor();
//    Agent agent = new Agent();
//    Intent intent = new Intent();
//    Map<String, String> headers = new HashMap<String, String>();
//    String headersString;
//    String stringRequest;
//    ObjectMapper mapper = new ObjectMapper();
//<<<<<<< HEAD
//    Response response = Response.builder().build();
//=======
//    Response response = new Response();
//>>>>>>> patch_headers
//
//    @BeforeEach
//    public void setup() throws JsonProcessingException {
//        populateHeaders();
//    }
//
//    @Test
//<<<<<<< HEAD
//    public void shouldReturnNackIfContextparamMissing() throws Exception {
//
//        MessageAck messageAckTo = new MessageAck();
//        Ack ack = Ack.builder().build();
//=======
//     void shouldReturnNackIfContextparamMissing() throws Exception {
//
//        MessageAck messageAckTo = new MessageAck();
//        Ack ack = new Ack();
//>>>>>>> patch_headers
//        ack.setStatus("NACK");
//        messageAckTo.setAck(ack);
//        Mono<String> resp = Mono.just(mapper.writeValueAsString(messageAckTo));
//
//        ctx.setAction("search");
//        ctx.setDomain("nic2004:85111");
//        // ctx.setCountry("IND"); // Any context value disable will make bad request
//        ctx.setCoreVersion("0.7.1");
//        ctx.setCity("std:080");
//        ctx.setConsumerId("eua-nha");
//        ctx.setConsumerUri("http://uhieuasandbox.abdm.gov.in/api/v1/euaService");
//        ctx.setMessageId(UUID.randomUUID() + "");
//        ctx.setTimestamp(System.currentTimeMillis() + "");
//        ctx.setTransactionId(UUID.randomUUID() + "");
//
//        desc.setCode("CARDIOLOGY");
//        desc.setName("CARDIOLOGY");
//        cat.setDescriptor(desc);
//        agent.setName("deepak");
//        ful.setType("Online");
//        ful.setAgent(agent);
//        desc.setCode("Consultation");
//        desc.setName("Consultation");
//        item.setDescriptor(desc);
//        intent.setCategory(cat);
//        intent.setFulfillment(ful);
//        intent.setItem(item);
//        msz.setIntent(intent);
//        request.setContext(ctx);
//        request.setMessage(msz);
//
//        stringRequest = mapper.writeValueAsString(request);
//
//        when(requesterServiceMock.processor(stringRequest, headers)).thenReturn(resp);
//
//        String jsonStringResponse = new String(
//                webTestClient.post().uri("/api/v1/search").header(headersString).body(BodyInserters.fromValue(request))
//                        .exchange().expectStatus().isBadRequest().expectBody().returnResult().getResponseBody());
//        Response response = mapper.readValue(jsonStringResponse, Response.class);
//        Assert.isTrue(response.getMessage().getAck().getStatus().equals("NACK"), "NACK");
//    }
//
//    @Test
//<<<<<<< HEAD
//    public void shouldReturnAck() throws Exception {
//=======
//     void shouldReturnAck() throws Exception {
//>>>>>>> patch_headers
//
//        ctx.setAction("search");
//        ctx.setDomain("nic2004:85111");
//        ctx.setCountry("IND");
//        ctx.setCoreVersion("0.7.1");
//        ctx.setCity("std:080");
//        ctx.setConsumerId("eua-nha");
//        ctx.setConsumerUri("http://uhieuasandbox.abdm.gov.in/api/v1/euaService");
//        ctx.setMessageId(UUID.randomUUID() + "");
//        ctx.setTimestamp(System.currentTimeMillis() + "");
//        ctx.setTransactionId(UUID.randomUUID() + "");
//
//        desc.setCode("CARDIOLOGY");
//        desc.setName("CARDIOLOGY");
//        cat.setDescriptor(desc);
//        agent.setName("deepak");
//        ful.setType("Online");
//        ful.setAgent(agent);
//        desc.setCode("Consultation");
//        desc.setName("Consultation");
//        item.setDescriptor(desc);
//        intent.setCategory(cat);
//        intent.setFulfillment(ful);
//        intent.setItem(item);
//        msz.setIntent(intent);
//        request.setContext(ctx);
//        request.setMessage(msz);
//
//        stringRequest = mapper.writeValueAsString(request);
//
//        MessageAck messageAckTo = new MessageAck();
//<<<<<<< HEAD
//        Ack ack = Ack.builder().build();
//=======
//        Ack ack = new Ack();
//>>>>>>> patch_headers
//        ack.setStatus("ACK");
//        messageAckTo.setAck(ack);
//        response.setMessage(messageAckTo);
//
//        Mono<String> resp = Mono.just(mapper.writeValueAsString(response));
//
//        when(requesterServiceMock.processor(stringRequest, headers)).thenReturn(resp);
//
//        webTestClient.post().uri("/api/v1/search").header(headersString).body(BodyInserters.fromValue(request))
//                .exchange().expectStatus().is2xxSuccessful();
//
//    }
//
//    private void populateHeaders() {
//
//        headers.put("Authorization", "");
//        headersString = String.valueOf(headers);
//        headersString = headersString.replaceAll("\\}", "");
//    }
//}
