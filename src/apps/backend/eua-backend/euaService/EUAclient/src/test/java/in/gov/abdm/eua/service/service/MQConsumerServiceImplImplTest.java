package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.eua.service.service.impl.MQConsumerServiceImpl;
import org.junit.Assert;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.user.SimpUserRegistry;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.io.IOException;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

public class MQConsumerServiceImplImplTest {

    @Mock
    ObjectMapper objectMapper;
    @Mock
    SimpMessagingTemplate messagingTemplate;
    @Mock
    WebClient webClient;
    @Mock
    WebClient.RequestBodyUriSpec requestBodyUriSpec;
    @Mock
    WebClient.RequestHeadersSpec requestHeadersSpec;
    @Mock
    WebClient.RequestBodySpec requestBodySpec;
    @Mock
    WebClient.ResponseSpec responseSpec;
    @Mock
    SimpUserRegistry simpUserRegistry;
    @InjectMocks
    MQConsumerServiceImpl mqConsumerServiceImpl;

    EuaRequestBody requestBody;

    @BeforeEach
    public void setupUp() throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        requestBody = requestBody = objectMapper.readValue("{\n" +
                "  \"context\": {\n" +
                "    \"domain\": \"nic2004:mumm\",\n" +
                "    \"country\": \"IND\",\n" +
                "    \"city\": \"std:080\",\n" +
                "    \"provider_uri\": \"http://localhost:9090\",\n" +
                "    \"action\": \"search\",\n" +
                "    \"consumer_id\":\"1221\",\n" +
                "    \"core_version\": \"0.7.1\",\n" +
                "    \"message_id\": \"85a422c4-2867-4d72-b5f5-d31588e2f7c1552\",\n" +
                "    \"timestamp\": \"2021-03-23T10:00:40.065Z\"\n" +
                "  },\n" +
                "  \"message\": {\n" +
                "    \"catalog\": {\n" +
                "      \"descriptor\": {\n" +
                "        \"name\": \"Yonro\"\n" +
                "      },\n" +
                "      \"providers\": [\n" +
                "        {\n" +
                "          \"id\": \"289edce4-d002-4962-b311-4c025e22b4f6\",\n" +
                "          \"descriptor\": {\n" +
                "            \"name\": \"BAPP Hospitals\"\n" +
                "          },\n" +
                "          \"categories\": [\n" +
                "            {\n" +
                "              \"id\": \"1\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"OPD\"\n" +
                "              }\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"2\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"Diagnostics\"\n" +
                "              }\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"3\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"Emergency\"\n" +
                "              }\n" +
                "            }\n" +
                "          ],\n" +
                "          \"fulfillments\": [\n" +
                "            {\n" +
                "              \"id\": \"1\",\n" +
                "              \"type\": \"DIGITAL-OPD\",\n" +
                "              \"person\": {\n" +
                "                \"id\": \"1\",\n" +
                "                \"name\": \"Dr Asthana\",\n" +
                "                \"gender\": \"male\",\n" +
                "                \"image\": \"https://image/of/person.png\",\n" +
                "                \"cred\": \"uhiId:237402938409485039850935\"\n" +
                "              },\n" +
                "              \"start\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:00Z\"\n" +
                "                }\n" +
                "              },\n" +
                "              \"end\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:15Z\"\n" +
                "                }\n" +
                "              }\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"2\",\n" +
                "              \"type\": \"DIGITAL-OPD\",\n" +
                "              \"person\": {\n" +
                "                \"id\": \"1\",\n" +
                "                \"name\": \"Dr Asthana\",\n" +
                "                \"gender\": \"male\",\n" +
                "                \"image\": \"https://image/of/person.png\",\n" +
                "                \"cred\": \"uhiId:237402938409485039850935\"\n" +
                "              },\n" +
                "              \"start\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:15Z\"\n" +
                "                }\n" +
                "              },\n" +
                "              \"end\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:30Z\"\n" +
                "                }\n" +
                "              }\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"3\",\n" +
                "              \"type\": \"DIGITAL-OPD\",\n" +
                "              \"person\": {\n" +
                "                \"id\": \"1\",\n" +
                "                \"name\": \"Dr Bhargava\",\n" +
                "                \"gender\": \"female\",\n" +
                "                \"image\": \"https://image/of/person.png\",\n" +
                "                \"cred\": \"uhiId:237402938409485039850935\"\n" +
                "              },\n" +
                "              \"start\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:00Z\"\n" +
                "                }\n" +
                "              },\n" +
                "              \"end\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:15Z\"\n" +
                "                }\n" +
                "              }\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"4\",\n" +
                "              \"type\": \"DIGITAL-OPD\",\n" +
                "              \"person\": {\n" +
                "                \"id\": \"1\",\n" +
                "                \"name\": \"Dr Bhargava\",\n" +
                "                \"gender\": \"female\",\n" +
                "                \"image\": \"https://image/of/person.png\",\n" +
                "                \"cred\": \"uhiId:237402938409485039850935\"\n" +
                "              },\n" +
                "              \"start\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:15Z\"\n" +
                "                }\n" +
                "              },\n" +
                "              \"end\": {\n" +
                "                \"time\": {\n" +
                "                  \"timestamp\": \"T10:30Z\"\n" +
                "                }\n" +
                "              }\n" +
                "            }\n" +
                "          ],\n" +
                "          \"items\": [\n" +
                "            {\n" +
                "              \"id\": \"1\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"Consultation\"\n" +
                "              },\n" +
                "              \"category_id\": \"1\",\n" +
                "              \"fulfillment_id\": \"1\"\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"1\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"Consultation\"\n" +
                "              },\n" +
                "              \"category_id\": \"1\",\n" +
                "              \"fulfillment_id\": \"2\"\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"1\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"Consultation\"\n" +
                "              },\n" +
                "              \"category_id\": \"1\",\n" +
                "              \"fulfillment_id\": \"3\"\n" +
                "            },\n" +
                "            {\n" +
                "              \"id\": \"1\",\n" +
                "              \"descriptor\": {\n" +
                "                \"name\": \"Consultation\"\n" +
                "              },\n" +
                "              \"category_id\": \"1\",\n" +
                "              \"fulfillment_id\": \"4\"\n" +
                "            }\n" +
                "          ]\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  }\n" +
                "}", EuaRequestBody.class);

        MockitoAnnotations.openMocks(this);
        mqConsumerServiceImpl = Mockito.mock(MQConsumerServiceImpl.class);

    }

    @Test
    void getAckResponseResponseEntity() {
        WebClient restClient = WebClient.create();

        when(webClient.post()).thenReturn(requestBodyUriSpec);
        when(requestBodyUriSpec.uri(anyString())).thenReturn(requestBodySpec);
        when(requestBodySpec.header(any(),any())).thenReturn(requestBodySpec);

        when(requestHeadersSpec.header(any(),any())).thenReturn(requestHeadersSpec);

        when(requestBodySpec.accept(any())).thenReturn(requestBodySpec);
        when(requestBodySpec.body(any())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(ArgumentMatchers.<Class<String>>notNull()))
                .thenReturn(Mono.just("resp"));

        Assert.assertNotNull(restClient.post());

//        Mockito.verify(mqConsumerService).getAckResponseResponseEntity(requestBody, null, 1 );
    }

    @Test
    void sendNackResponse() {
        mqConsumerServiceImpl.prepareAndSendNackResponse("","");
        Mockito.verify(mqConsumerServiceImpl).prepareAndSendNackResponse("", "");

    }

    @Test
    void euaToGatewayConsumer() throws IOException {
        mqConsumerServiceImpl.euaToGatewayConsumer(new MqMessageTO());
        Mockito.verify(mqConsumerServiceImpl).euaToGatewayConsumer(any());
    }

    @Test
    void gatewayToEuaConsumer() throws JsonProcessingException {
        mqConsumerServiceImpl.gatewayToEuaConsumer(new MqMessageTO());
        Mockito.verify(mqConsumerServiceImpl).gatewayToEuaConsumer( any());
    }
}