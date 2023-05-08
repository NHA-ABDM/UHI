//<<<<<<< HEAD
//package in.gov.abdm.uhi.discovery.controller;
//
//import com.fasterxml.jackson.core.JsonProcessingException;
//import com.fasterxml.jackson.databind.ObjectMapper;
//import in.gov.abdm.uhi.common.dto.*;
//import in.gov.abdm.uhi.discovery.service.ResponderService;
//import org.junit.jupiter.api.BeforeEach;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
//import org.springframework.boot.test.mock.mockito.MockBean;
//import org.springframework.test.web.reactive.server.WebTestClient;
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
//public class ResponderControllerTest {
//
//    @Autowired
//    WebTestClient webTestClient;
//
//    @MockBean
//    ResponderService responderServiceMock;
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
//    Response response = Response.builder().build();
//
//    @BeforeEach
//    public void setup() throws JsonProcessingException {
//        populateHeaders();
//    }
//
//    private void populateHeaders() {
//
//        headers.put("Authorization", "");
//        headersString = String.valueOf(headers);
//        headersString = headersString.replaceAll("\\}", "");
//    }
//
//
//    public void shouldReturnAck() throws Exception {
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
//        MessageAck messageAckTo = new MessageAck();
//        Ack ack = Ack.builder().build();
//        ack.setStatus("ACK");
//        messageAckTo.setAck(ack);
//        response.setMessage(messageAckTo);
//
//        stringRequest = mapper.writeValueAsString(request);
//
//        Mono<String> resp = Mono.just(mapper.writeValueAsString(response));
//
//        when(responderServiceMock.processor(stringRequest, headers)).thenReturn(resp);
//
//        webTestClient.post().uri("/api/v1/on_search").header(headersString).body(BodyInserters.fromValue(stringRequest))
//                .exchange().expectStatus().is2xxSuccessful();
//    }
//}
//=======
////package in.gov.abdm.uhi.discovery.controller;
////
////import com.fasterxml.jackson.core.JsonProcessingException;
////import com.fasterxml.jackson.databind.ObjectMapper;
////import in.gov.abdm.uhi.common.dto.*;
////import in.gov.abdm.uhi.discovery.service.ResponderService;
////import org.junit.jupiter.api.BeforeEach;
////import org.springframework.beans.factory.annotation.Autowired;
////import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
////import org.springframework.boot.test.mock.mockito.MockBean;
////import org.springframework.test.web.reactive.server.WebTestClient;
////import org.springframework.web.reactive.function.BodyInserters;
////import reactor.core.publisher.Mono;
////
////import java.util.HashMap;
////import java.util.Map;
////import java.util.UUID;
////
////import static org.mockito.Mockito.when;
////
////@WebFluxTest(RequesterController.class)
////public class ResponderControllerTest {
////
////    @Autowired
////    WebTestClient webTestClient;
////
////    @MockBean
////    ResponderService responderServiceMock;
////
////    Message msz = new Message();
////    Context ctx = new Context();
////    Request request = new Request();
////    Category cat = new Category();
////    Fulfillment ful = new Fulfillment();
////    Item item = new Item();
////    Descriptor desc = new Descriptor();
////    Agent agent = new Agent();
////    Intent intent = new Intent();
////    Map<String, String> headers = new HashMap<String, String>();
////    String headersString;
////    String stringRequest;
////    ObjectMapper mapper = new ObjectMapper();
////    Response response = new Response();
////
////    @BeforeEach
////    public void setup() throws JsonProcessingException {
////        populateHeaders();
////    }
////
////    private void populateHeaders() {
////
////        headers.put("Authorization", "");
////        headersString = String.valueOf(headers);
////        headersString = headersString.replaceAll("\\}", "");
////    }
////
////
////    public void shouldReturnAck() throws Exception {
////        ctx.setAction("search");
////        ctx.setDomain("nic2004:85111");
////        ctx.setCountry("IND");
////        ctx.setCoreVersion("0.7.1");
////        ctx.setCity("std:080");
////        ctx.setConsumerId("eua-nha");
////        ctx.setConsumerUri("http://uhieuasandbox.abdm.gov.in/api/v1/euaService");
////        ctx.setMessageId(UUID.randomUUID() + "");
////        ctx.setTimestamp(System.currentTimeMillis() + "");
////        ctx.setTransactionId(UUID.randomUUID() + "");
////
////        MessageAck messageAckTo = new MessageAck();
////        Ack ack = new Ack();
////        ack.setStatus("ACK");
////        messageAckTo.setAck(ack);
////        response.setMessage(messageAckTo);
////
////        stringRequest = mapper.writeValueAsString(request);
////
////        Mono<String> resp = Mono.just(mapper.writeValueAsString(response));
////
////        when(responderServiceMock.processor(stringRequest, headers)).thenReturn(resp);
////
////        webTestClient.post().uri("/api/v1/on_search").header(headersString).body(BodyInserters.fromValue(stringRequest))
////                .exchange().expectStatus().is2xxSuccessful();
////    }
////}
//>>>>>>> patch_headers
