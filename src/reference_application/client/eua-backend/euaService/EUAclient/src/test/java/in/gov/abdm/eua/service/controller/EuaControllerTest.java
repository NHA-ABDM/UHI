package in.gov.abdm.eua.service.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;
import in.gov.abdm.uhi.common.dto.MessageAck;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;
import org.springframework.context.annotation.Description;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;


public class EuaControllerTest {

    @InjectMocks
    EuaController euaController;

    EuaRequestBody requestBody;

    MessageAck MessageAck;

    ObjectMapper objectMapper;

    @BeforeEach
    public void setUp() throws JsonProcessingException {
        objectMapper = new ObjectMapper();
        MockitoAnnotations.openMocks(this);
        requestBody = objectMapper.readValue("{\n" +
                "  \"context\": {\n" +
                "    \"domain\": \"nic2004:mumm\",\n" +
                "    \"country\": \"IND\",\n" +
                "    \"city\": \"std:080\",\n" +
                "    \"provider_uri\": \"http://localhost:9090\",\n" +
                "    \"consumer_uri\": \"http://localhost:9090\",\n" +
                "    \"transaction_id\": \"svdsdvsdv\",\n" +
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
        String nack = "{ \"message\": { \"ack\": { \"status\": \"NACK\" } }, \"error\": { \"type\": \"\", \"code\": \"500\", \"path\": \"string\", \"message\": \"Something went wrong\" } }";
        MessageAck = objectMapper.readValue(nack, MessageAck.class);
    }

    @Test
    public void contextLoads() {
        Assertions.assertThat(euaController).isNotNull();
    }

    @Test
    @Description("To test context value should not be null for on search method call")
    public void givenResponseForOnSearchContextShouldNotBeNull() throws JsonProcessingException {
        requestBody.setContext(null);
        MessageAck.getAck().setStatus("Context is Null");
        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
        Assertions.assertThat(euaController.onSearch(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);

    }

    @Test
    @Description("To test message value should not be null for on search method call")
    public void givenResponseForOnSearchMessageShouldNotBeNull() throws JsonProcessingException {
        requestBody.setMessage(null);
        MessageAck.getAck().setStatus("Message is Null");
        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
        Assertions.assertThat(euaController.onSearch(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);

    }

    @Test
    @Description("To test all mandatory fields are present in the context")
    public void givenResponseForOnSearchAllMandatoryFieldsForContextPresent() throws JsonProcessingException {
        makeContextMandatoryFieldsNull();

        MessageAck.getAck().setStatus("Mandatory fields on context are Null");
        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
        Assertions.assertThat(euaController.onSearch(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);
    }

    private void makeContextMandatoryFieldsNull() {
        requestBody.getContext().setConsumerUri(null);
        requestBody.getContext().setConsumerId(null);
        requestBody.getContext().setAction(null);
        requestBody.getContext().setCity(null);
        requestBody.getContext().setCountry(null);
        requestBody.getContext().setDomain(null);
        requestBody.getContext().setTimestamp(null);
        requestBody.getContext().setTransactionId(null);
        requestBody.getContext().setCoreVersion(null);
        requestBody.getContext().setMessageId(null);
    }

//    @Test
//    @Description("To test that person name is not null")
//    public void givenResponseForOnSearchPersonNameShouldNotBeNull() throws JsonProcessingException {
//        requestBody.getMessage().getCatalog().getProviders().get(0).getFulfillments().get(0).getPerson().setName(null);
//        requestBody.getMessage().getCatalog().getProviders().add(requestBody.getMessage().getCatalog().getProviders().get(0));
//        MessageAck.getError().setMessage("Mandatory field person name in one of the result is null");
//        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
//        Assertions.assertThat(euaController.onSearch(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);
//    }

    @Test
    @Description("To test that when called search context should not be null")
    public void givenRequestForSearchContextShouldNotBeNull() throws JsonProcessingException {
        requestBody.setContext(null);
        MessageAck.getAck().setStatus("Context is Null");
        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
        Assertions.assertThat(euaController.search(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);
    }

    @Test
    @Description("To test that when called search context should not be null")
    public void givenRequestForSearchMessageShouldNotBeNull() throws JsonProcessingException {
        requestBody.setMessage(null);
        MessageAck.getAck().setStatus("Message is Null");
        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
        Assertions.assertThat(euaController.search(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);
    }

    @Test
    @Description("To test all mandatory fields are present in the context for search")
    public void givenResponseForSearchAllMandatoryFieldsForContextPresent() throws JsonProcessingException {
        makeContextMandatoryFieldsNull();

        MessageAck.getAck().setStatus("Mandatory fields on context are Null");
        ResponseEntity<MessageAck> MessageAckResponseEntity = new ResponseEntity<>(MessageAck, HttpStatus.INTERNAL_SERVER_ERROR);
        Assertions.assertThat(euaController.search(String.valueOf(requestBody))).isEqualTo(MessageAckResponseEntity);
    }


}