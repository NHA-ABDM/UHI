package in.gov.abdm.eua.service.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.dto.dhp.AckResponseDTO;
import in.gov.abdm.eua.service.dto.dhp.EuaRequestBody;
import in.gov.abdm.eua.service.dto.dhp.MqMessageTO;
import in.gov.abdm.eua.service.service.impl.EuaServiceImpl;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public class EuaServiceTest {

    RabbitTemplate rabbitTemplate;

    @Mock
    ObjectMapper objectMapper;

    @InjectMocks
    EuaServiceImpl euaService;

    MqMessageTO message;

    @BeforeEach
    public void setUp() {

        rabbitTemplate = Mockito.mock(RabbitTemplate.class);
        MockitoAnnotations.openMocks(this);

        String dateTime = LocalDateTime.now().toString();
        message = new MqMessageTO();
        message.setResponse("response");
        message.setMessageId("129iedjed");
        message.setCreatedAt(dateTime);
        message.setDhpQueryType("search");
        message.setConsumerId("121223");
    }

    @Test
    void testGetOnAckResponseResponseEntityForAck() throws JsonProcessingException {
        String ack = "{\n" +
                "    \"message\": {\n" +
                "        \"ack\": {\n" +
                "            \"status\": \"ACK\"\n" +
                "        }\n" +
                "    },\n" +
                "    \"error\": null\n" +
                "}";
        AckResponseDTO ackResponseDTO = objectMapper.readValue(ack, AckResponseDTO.class);
        ResponseEntity<AckResponseDTO> ans = ResponseEntity.status(HttpStatus.OK).body(ackResponseDTO);

        Assertions.assertThat(euaService.getOnAckResponseResponseEntity(objectMapper, "sdvsdvsdvsdvsd", "search", "requestMessageId")).isEqualTo(ans);

    }

    @Test
    void testGetOnAckResponseResponseEntityForNack() throws JsonProcessingException {
        String ack = "{ \"message\": { \"ack\": { \"status\": \"NACK\" } }, \"error\": { \"type\": \"\", \"code\": \"500\", \"path\": \"string\", \"message\": \"Something went wrong\" } }";
        AckResponseDTO ackResponseDTO = objectMapper.readValue(ack, AckResponseDTO.class);
        ResponseEntity<AckResponseDTO> ans = ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ackResponseDTO);


        Assertions.assertThat(euaService.getOnAckResponseResponseEntity(objectMapper, null, "search", "requestMessageId")).isEqualTo(ans);

    }
    @Test
    void testExtractMessage() {
        String dateTime = LocalDateTime.now().toString();
        MqMessageTO message = new MqMessageTO();
        message.setResponse("response");
        message.setMessageId("129iedjed");
        message.setCreatedAt(dateTime);
        message.setDhpQueryType("search");
        message.setConsumerId("121223");

        MqMessageTO testMesssage = euaService.extractMessage("129iedjed", "121223", "response", "search");

        testMesssage.setCreatedAt(dateTime);

        Assertions.assertThat(testMesssage).isEqualTo(message);
    }

    @Test
    public void testRabbitMq() throws JsonProcessingException {
        final EuaRequestBody requestBody;
        ObjectMapper objectMapper = new ObjectMapper();

        requestBody = objectMapper.readValue("""
                {
                  "context": {
                    "domain": "nic2004:mumm",
                    "country": "IND",
                    "city": "std:080",
                    "provider_uri": "http://localhost:9090",
                    "action": "search",
                    "consumer_id":"1221",
                    "core_version": "0.7.1",
                    "message_id": "85a422c4-2867-4d72-b5f5-d31588e2f7c1552",
                    "timestamp": "2021-03-23T10:00:40.065Z"
                  },
                  "message": {
                    "catalog": {
                      "descriptor": {
                        "name": "Yonro"
                      },
                      "providers": [
                        {
                          "id": "289edce4-d002-4962-b311-4c025e22b4f6",
                          "descriptor": {
                            "name": "BAPP Hospitals"
                          },
                          "categories": [
                            {
                              "id": "1",
                              "descriptor": {
                                "name": "OPD"
                              }
                            },
                            {
                              "id": "2",
                              "descriptor": {
                                "name": "Diagnostics"
                              }
                            },
                            {
                              "id": "3",
                              "descriptor": {
                                "name": "Emergency"
                              }
                            }
                          ],
                          "fulfillments": [
                            {
                              "id": "1",
                              "type": "DIGITAL-OPD",
                              "person": {
                                "id": "1",
                                "name": "Dr Asthana",
                                "gender": "male",
                                "image": "https://image/of/person.png",
                                "cred": "uhiId:237402938409485039850935"
                              },
                              "start": {
                                "time": {
                                  "timestamp": "T10:00Z"
                                }
                              },
                              "end": {
                                "time": {
                                  "timestamp": "T10:15Z"
                                }
                              }
                            },
                            {
                              "id": "2",
                              "type": "DIGITAL-OPD",
                              "person": {
                                "id": "1",
                                "name": "Dr Asthana",
                                "gender": "male",
                                "image": "https://image/of/person.png",
                                "cred": "uhiId:237402938409485039850935"
                              },
                              "start": {
                                "time": {
                                  "timestamp": "T10:15Z"
                                }
                              },
                              "end": {
                                "time": {
                                  "timestamp": "T10:30Z"
                                }
                              }
                            },
                            {
                              "id": "3",
                              "type": "DIGITAL-OPD",
                              "person": {
                                "id": "1",
                                "name": "Dr Bhargava",
                                "gender": "female",
                                "image": "https://image/of/person.png",
                                "cred": "uhiId:237402938409485039850935"
                              },
                              "start": {
                                "time": {
                                  "timestamp": "T10:00Z"
                                }
                              },
                              "end": {
                                "time": {
                                  "timestamp": "T10:15Z"
                                }
                              }
                            },
                            {
                              "id": "4",
                              "type": "DIGITAL-OPD",
                              "person": {
                                "id": "1",
                                "name": "Dr Bhargava",
                                "gender": "female",
                                "image": "https://image/of/person.png",
                                "cred": "uhiId:237402938409485039850935"
                              },
                              "start": {
                                "time": {
                                  "timestamp": "T10:15Z"
                                }
                              },
                              "end": {
                                "time": {
                                  "timestamp": "T10:30Z"
                                }
                              }
                            }
                          ],
                          "items": [
                            {
                              "id": "1",
                              "descriptor": {
                                "name": "Consultation"
                              },
                              "category_id": "1",
                              "fulfillment_id": "1"
                            },
                            {
                              "id": "1",
                              "descriptor": {
                                "name": "Consultation"
                              },
                              "category_id": "1",
                              "fulfillment_id": "2"
                            },
                            {
                              "id": "1",
                              "descriptor": {
                                "name": "Consultation"
                              },
                              "category_id": "1",
                              "fulfillment_id": "3"
                            },
                            {
                              "id": "1",
                              "descriptor": {
                                "name": "Consultation"
                              },
                              "category_id": "1",
                              "fulfillment_id": "4"
                            }
                          ]
                        }
                      ]
                    }
                  }
                }""", EuaRequestBody.class);
        MqMessageTO message = new MqMessageTO();
        message.setCreatedAt(LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS).toString());
        message.setMessageId("Test");
        message.setResponse("Test");
        message.setConsumerId("Test");
        message.setDhpQueryType("search");

        Assertions.assertThatCode(() -> this.euaService.pushToMq( new ObjectMapper().writeValueAsString(requestBody), "sdcs","Test","sdcsd")).doesNotThrowAnyException();
        Mockito.verify(this.rabbitTemplate)
                .convertAndSend(ConstantsUtils.EXCHANGE, ConstantsUtils.ROUTING_KEY_EUA_TO_GATEWAY, message);
    }

}