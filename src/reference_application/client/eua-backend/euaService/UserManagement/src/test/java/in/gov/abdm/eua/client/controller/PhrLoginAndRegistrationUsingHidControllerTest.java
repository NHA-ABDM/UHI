package in.gov.abdm.eua.client.controller;

import in.gov.abdm.eua.userManagement.controller.PhrLoginAndRegistrationUsingHidController;
import in.gov.abdm.eua.userManagement.dto.phr.LoginViaMobileEmailRequestResponse;
import in.gov.abdm.eua.userManagement.dto.phr.SearchResponsePayLoad;
import in.gov.abdm.eua.userManagement.dto.phr.login.AuthConfirmResponse;
import in.gov.abdm.eua.userManagement.dto.phr.login.AuthInitResponse;
import in.gov.abdm.eua.userManagement.dto.phr.registration.HidResponse;
import in.gov.abdm.eua.userManagement.dto.phr.registration.JwtResponseHid;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Description;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

public class PhrLoginAndRegistrationUsingHidControllerTest {

    @Mock
    WebClient webClient;

    @InjectMocks
    PhrLoginAndRegistrationUsingHidController controller;

    @Autowired
    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    //TC for hid/confirmInit begins

    @Test
    @Description("To test that method should give 400 bad request when request body is null")
    public void whenGivenNullRequestForFindUserByHealthId_shouldGive400BadReq() {
        Mono<SearchResponsePayLoad> responsePayLoad = Mono.just(new SearchResponsePayLoad());
        responsePayLoad.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });

        final ResponseEntity<Mono<SearchResponsePayLoad>> errorResponse = ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        Assertions.assertThat(controller.findUserByHealthId(null, null).toString()).isEqualTo(errorResponse.toString());
    }

    @Test
    @Description("To test that given null healhtIdNumber should return 400 bad request")
    public void givenNullAuthcodeShouldReturn400Error() throws Exception {
        String request = """
                {
                   "healhtIdNumber": null
                 }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/search/auth-mode")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    //TC for /reg/hid/confirmInit ends
    //TC for /registration/hid/auth-init begins
    @Test
    @Description("To test that method should give 400 bad request when request body is null")
    public void whenGivenNullRequestForGenerateTransactionOtp_shouldGive400BadReq() {
        SearchResponsePayLoad responsePayLoad = new SearchResponsePayLoad();
        responsePayLoad.getError().setErrorString("Request cannot be null");
        responsePayLoad.getError().setCode("400");
        final ResponseEntity<SearchResponsePayLoad> errorResponse = ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        Assertions.assertThat(controller.findUserByHealthId(null, null)).isNotNull();
    }

    @Test
    @Description("To test that given null healhtId should return 400 bad request")
    public void givenNullHealthIdNumber_ShouldReturn400Error() throws Exception {
        String request = """
                {
                        "healthid": "",
                        "authMethod": "MOBILE_OTP"
                    }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null authMode should return 400 bad request")
    public void givenNullAuthModeRegisterAbhaId_ShouldReturn400Error() throws Exception {
        String request = """
                {
                         "healthid": "78-4151-6718-2044",
                         "authMethod": ""
                     }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }


//    @Test
//    @Description("To test that given invalid healhtIdNumber should return 400 bad request")
//    public void giveninvalidHealthIdNumber_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                     "healthIdNumber": "11acdscds11222233334",
//                     "purpose": "CM_ACCESS",
//                     "authMode": "MOBILE_OTP",
//                     "requester": {
//                       "type": "PHR",
//                       "id": "IN0400XX"
//                     }
//                   }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }
//
//    @Test
//    @Description("To test that given null purpose should return 400 bad request")
//    public void givenNullPurpose_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                     "healthIdNumber": "01928374651029",
//                    "purpose": null,
//                     "authMode": "MOBILE_OTP",
//                     "requester": {
//                       "type": "PHR",
//                       "id": "IN0400XX"
//                     }
//                   }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }
//
//
//    @Test
//    @Description("To test that given null authMode should return 400 bad request")
//    public void givenNullAuthMode_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                     "healthIdNumber": "01928374651029",
//                      "purpose": "CM_ACCESS",
//                     "authMode": null,
//                     "requester": {
//                       "type": "PHR",
//                       "id": "IN0400XX"
//                     }
//                   }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }
//
//    @Test
//    @Description("To test that given null Requester should return 400 bad request")
//    public void givenNullRequester_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                     "healthIdNumber": "01928374651029",
//                      "purpose": "CM_ACCESS",
//                      "authMode": "MOBILE_OTP",
//                     "requester": null
//                   }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }
//
//    @Test
//    @Description("To test that given null Requester.type should return 400 bad request")
//    public void givenNullRequesterType_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                     "healthIdNumber": "01928374651029",
//                      "purpose": "CM_ACCESS",
//                      "authMode": "MOBILE_OTP",
//                     "requester": {
//                       "type": null,
//                       "id": "IN0400XX"
//                     }
//                   }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }
//
//    @Test
//    @Description("To test that given null Requester.id should return 400 bad request")
//    public void givenNullRequesterId_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                     "healthIdNumber": "01928374651029",
//                      "purpose": "CM_ACCESS",
//                      "authMode": "MOBILE_OTP",
//                     "requester": {
//                       "type": "PHR",
//                       "id": null
//                     }
//                   }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }
//TC for /registration/hid/auth-init ends
// TC for /registration/hid/confirm-init begins

    @Test
    @Description("To test that given null Request should return 400 bad request")
    public void givenNullRequestForConfirmInit_ShouldReturn400Error() throws Exception {
        Mono<HidResponse> hidResponse;
        hidResponse = Mono.just(new HidResponse());
        hidResponse.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });

        ResponseEntity<Mono<HidResponse>> errorBody = ResponseEntity.status(HttpStatus.BAD_REQUEST).body(hidResponse);
        Assertions.assertThat(controller.verifyUserOtp(null, null).toString()).isEqualTo(errorBody.toString());
    }


    @Test
    @Description("To test that given null Requester.id should return 400 bad request")
    public void givenNullSessionIdForConfirmInit_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "sessionId": null,
                      "value": "sw1uD+gpv3fj6NHBNhtcII3GksVtkLT9bvcz0svYDyUt/x3jTtedXSYgw4b90GTwfLfs1eow056VsOw9HFS/wB8uH5Ysx+QzpL7PxmAY1WOHwOj04sPKN6Dw8XY8vcXovtvZc1dUB+TPAlGGPNu8iqMVPetukysjRxgbNdLLKMxn46rIRb8NieeyuDx1EHa90jJP9KwKGZdsLr08BysrmMJExzTO9FT93CzoNg50/nxzaQgmkBSbu9D8DxJm7XrLzWSUB05YCknHbokm4iXwyYBsrmfFDE/xCDfzYPhYyhtEmOi4J/GMp+lO+gAHQFQtxkIADhoSR8WXGcAbCUj7uTjFsBU/tc+RtvSotso4FXy8v+Ylzj28jbFTmmOWyAwYi9pThQjXnmRnq43dVdd5OXmxIII6SXs0JzoFvKwSk7VxhuLIRYzKqrkfcnWMrrmRgE8xZ6ZLft6O3IeiHb9WA8b/6/qO8Hdd17FKsSF6te59gSpoajS0FtQIgFn/c+NHzQYo5ZdsuRGM9v+bhHTInI="
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/confirm-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null Requester.id should return 400 bad request")
    public void givenNullValueForConfirmInit_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "sessionId": "a825f76b-0696-40f3-864c-5a3a5b389a83",
                      "value": null
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/confirm-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null Requester.id should return 400 bad request")
    public void givenNullValueForAllFields_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "sessionId": null,
                      "value": null
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/confirm-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }
// TC for /registration/hid/confirm-init ends
// TC for /registration/hid/create/phrAddress begins

    @Test
    @Description("To test that given null Request should return 400 bad request")
    public void givenNullRequestForCreatePhr_ShouldReturn400Error() throws Exception {
        Mono<JwtResponseHid> response = Mono.just(new JwtResponseHid());
        response.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });

        ResponseEntity<Mono<JwtResponseHid>> errorBody = ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        Assertions.assertThat(controller.createPhrAddress(null, null, null).toString()).isEqualTo(errorBody.toString());
    }

//    @Test
//    @Description("To test that given null Requester.id should return 400 bad request")
//    public void givenNullValueForAllFields_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                   "alreadyExistedPHR": true,
//                   "password": "HNceo964MVndrs8Z2oMtzIsmmbzagveHbWkDsDKskTue+/YZhHHrMon19J03ggU457upzWMIX0nU3d38xjB3FxA2qWCVmvLZ98A9l0y3i33vq1ywu9cORGF4OEqV8l7H9h4tDnLGDHnbOh9ct85VfOohP4p73lqW6WQSMYcU+xkBfEsRj42pWL19EVsE1UULtQE8gYY1B0SeM63svUp1kQ4Pt5hdgKxibYBq+hRcck2PkEIhp2N7AkjH4Tf+AhXU9956WLwjKgAKMk7K4+Zv8JtxYCcblQitbpN4ImPH5edf4mO5R/L9RpdAVSllAQQfPIDlp5ZGOZ1GrSmhzOSP3g==",
//                   "phrAddress": "user@abdm",
//                   "sessionId": "a825f76b-0696-40f3-864c-5a3a5b389a83"
//                 }
//
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(controller).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/confirm-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest())
//                .andExpect(MockMvcResultMatchers.content()
//                        .contentType(MediaType.APPLICATION_JSON));
//    }


    @Test
    @Description("To test that given all mandatory null values should return 400 bad request")
    public void givenNullValueForAllFieldsForCreatePhr_ShouldReturn400Error() throws Exception {
        String request = """
                {
                   "alreadyExistedPHR": true,
                   "password": "sdvsdvsdjvdlvsdvlsdlvvvnjslvsdklsdlvnldv",
                   "phrAddress": null,
                   "sessionId": null
                 }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/create/phrAddress")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null phrAddress for create Phr should return 400 bad request")
    public void givenNullValueForPhrAddressForCreatePhr_ShouldReturn400Error() throws Exception {
        String request = """
                {
                     "alreadyExistedPHR": true,
                     "password": "HNceo964MVndrs8Z2oMtzIsmmbzagveHbWkDsDKskTue+/YZhHHrMon19J03ggU457upzWMIX0nU3d38xjB3FxA2qWCVmvLZ98A9l0y3i33vq1ywu9cORGF4OEqV8l7H9h4tDnLGDHnbOh9ct85VfOohP4p73lqW6WQSMYcU+xkBfEsRj42pWL19EVsE1UULtQE8gYY1B0SeM63svUp1kQ4Pt5hdgKxibYBq+hRcck2PkEIhp2N7AkjH4Tf+AhXU9956WLwjKgAKMk7K4+Zv8JtxYCcblQitbpN4ImPH5edf4mO5R/L9RpdAVSllAQQfPIDlp5ZGOZ1GrSmhzOSP3g==",
                     "phrAddress": null,
                     "sessionId": "a825f76b-0696-40f3-864c-5a3a5b389a83"
                   }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/create/phrAddress")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null phrAddress for create Phr should return 400 bad request")
    public void givenNullValueForsessionIdForCreatePhr_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "alreadyExistedPHR": true,
                      "password": "HNceo964MVndrs8Z2oMtzIsmmbzagveHbWkDsDKskTue+/YZhHHrMon19J03ggU457upzWMIX0nU3d38xjB3FxA2qWCVmvLZ98A9l0y3i33vq1ywu9cORGF4OEqV8l7H9h4tDnLGDHnbOh9ct85VfOohP4p73lqW6WQSMYcU+xkBfEsRj42pWL19EVsE1UULtQE8gYY1B0SeM63svUp1kQ4Pt5hdgKxibYBq+hRcck2PkEIhp2N7AkjH4Tf+AhXU9956WLwjKgAKMk7K4+Zv8JtxYCcblQitbpN4ImPH5edf4mO5R/L9RpdAVSllAQQfPIDlp5ZGOZ1GrSmhzOSP3g==",
                      "phrAddress": "user@abdm",
                      "sessionId": null
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/registration/hid/create/phrAddress")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    // TC for /registration/hid/create/phrAddress ends
// TC for /login/hid/auth-init begins
    @Test
    @Description("To test when provided null request for login hid auth init should give bad request")
    public void givenNullRequestForHidLoginAuthInit_ShouldGiveBadReq() {
        Mono<LoginViaMobileEmailRequestResponse> response = Mono.just(new LoginViaMobileEmailRequestResponse());
        response.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });

        ResponseEntity<Mono<LoginViaMobileEmailRequestResponse>> errorBody = ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        Assertions.assertThat(controller.generateOtpForHidLogin(null, null, null).toString()).isEqualTo(errorBody.toString());
    }

    @Test
    @Description("To test that given null all mandatory parameters for login hid auth init should return 400 bad request")
    public void givenNullValueForLoginHidAuthInit_ShouldReturn400Error() throws Exception {
        String request = """
                {
                        "healthIdNumber": null,
                        "purpose": null,
                        "authMode": null,
                        "requester": {
                          "type": null,
                          "id": null
                        }
                      }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter healthIdNumber for login hid auth init should return 400 bad request")
    public void givenNullValueForLoginHidHealthIdNumber_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "healthIdNumber": "",
                      "purpose": "CM_ACCESS",
                      "authMode": "MOBILE_OTP",
                      "requester": {
                        "type": "PHR",
                        "id": "IN0400XX"
                      }
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter healthIdNumber for login hid auth init should return 400 bad request")
    public void givenInvalidValueForLoginHidHealthIdNumber_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "healthIdNumber": "64-4737-41870036",
                      "purpose": "CM_ACCESS",
                      "authMode": "MOBILE_OTP",
                      "requester": {
                        "type": "PHR",
                        "id": "IN0400XX"
                      }
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter purpose for login hid auth init should return 400 bad request")
    public void givenNullValueForLoginHidPurpose_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "healthIdNumber": "asdsd",
                      "purpose": "",
                      "authMode": "MOBILE_OTP",
                      "requester": {
                        "type": "PHR",
                        "id": "IN0400XX"
                      }
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter authMode for login hid auth init should return 400 bad request")
    public void givenNullValueForLoginHidAuthMode_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "healthIdNumber": "asdsd",
                     "purpose": "CM_ACCESS",
                      "authMode": "",
                      "requester": {
                        "type": "PHR",
                        "id": "IN0400XX"
                      }
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter Requester.type for login hid auth init should return 400 bad request")
    public void givenNullValueForLoginHidRequesterType_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "healthIdNumber": "asdsd",
                     "purpose": "CM_ACCESS",
                      "authMode": "MOBILE_OTP",
                      "requester": {
                        "type": "",
                        "id": "IN0400XX"
                      }
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter Requester.id for login hid auth init should return 400 bad request")
    public void givenNullValueForLoginHidRequesterId_ShouldReturn400Error() throws Exception {
        String request = """
                {
                      "healthIdNumber": "asdsd",
                     "purpose": "CM_ACCESS",
                      "authMode": "MOBILE_OTP",
                      "requester": {
                        "type": "PHR",
                        "id": ""
                      }
                    }

                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    // TC for /login/hid/auth-init ends
//TC for/login/hid/search/auth-mode begins
    @Test
    @Description("To test given null request for login hid search authMode should give bad request")
    public void givenNullRequestForLoginSearchAuthMode_SHouldGiveBadReq() {
        Mono<SearchResponsePayLoad> response = Mono.just(new SearchResponsePayLoad());
        response.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });

        Assertions.assertThat(controller.searchUserByHealthIdForLogin(null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
    }


    @Test
    @Description("To test that given null mandatory parameter healthIdNumber for login hid auth mode should return 400 bad request")
    public void givenNullValueForLoginHidAuthModeHealthIdNumber_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "healthIdNumber": null,
                  "yearOfBirth": "1994"
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/search/auth-mode")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter yearOfBirth for login hid auth mode should return 400 bad request")
    public void givenNullValueForLoginHidAuthModeYearOfBirth_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "healthIdNumber": "11-1111-1111-1111",
                  "yearOfBirth": null
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/search/auth-mode")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory parameter yearOfBirth for login hid auth mode should return 400 bad request")
    public void givenInvalidValueForLoginHidAuthModeHealthIdNumber_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "healthIdNumber": "dscsdsdfv",
                  "yearOfBirth": "1994"
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/search/auth-mode")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given all null mandatory fields for login hid auth mode should return 400 bad request")
    public void givenNullValueForAllMandatoryFieldsLoginHidAuthMode_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "healthIdNumber": null,
                  "yearOfBirth": null
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/hid/search/auth-mode")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }
//TC for/login/hid/search/auth-mode ends
//TC for/login/hid/search/auth-init begins

    @Test
    @Description("To test given null request for login phraddress authInit should return 400 bad req")
    public void givenNullRequestForLoginPhrAuthInit_ShouldReturnBadReq() {
        Mono<AuthInitResponse> response = Mono.just(new AuthInitResponse());
        response.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });
        Assertions.assertThat(controller.generateOtpPhrLogin(null, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
    }

    @Test
    @Description("To test that given all null mandatory fields for login phrAddress auth init should return 400 bad request")
    public void givenNullValueForAllMandatoryFieldsLoginPhrAuthInit_ShouldReturn400Error() throws Exception {
        String request = """
                {
                   "patientId": "",
                   "purpose": "",
                   "authMode": "",
                   "requester": {
                     "type": "",
                     "id": ""
                   }
                 }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field patientId for login phrAddress auth init should return 400 bad request")
    public void givenNullValueForMandatoryFieldPatientId_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "patientId": "",
                  "purpose": "CM_ACCESS",
                  "authMode": "MOBILE_OTP",
                  "requester": {
                    "type": "PHR",
                    "id": "IN0400XX"
                  }
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field purpose for login phrAddress auth init should return 400 bad request")
    public void givenNullValueForMandatoryFieldPurpose_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "patientId": "hinapatel@sbx",
                  "purpose": "",
                  "authMode": "MOBILE_OTP",
                  "requester": {
                    "type": "PHR",
                    "id": "IN0400XX"
                  }
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field AuthMode for login phrAddress auth init should return 400 bad request")
    public void givenNullValueForMandatoryFieldAuthMode_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "patientId": "hinapatel@sbx",
                  "purpose": "CM_ACCESS",
                  "authMode": "",
                  "requester": {
                    "type": "PHR",
                    "id": "IN0400XX"
                  }
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field Requester.type for login phrAddress auth init should return 400 bad request")
    public void givenNullValueForMandatoryFieldRequesterType_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "patientId": "hinapatel@sbx",
                  "purpose": "CM_ACCESS",
                  "authMode": "MOBILE_OTP",
                  "requester": {
                    "type": "",
                    "id": "IN0400XX"
                  }
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field Requester.id for login phrAddress auth init should return 400 bad request")
    public void givenNullValueForMandatoryFieldRequesterId_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "patientId": "hinapatel@sbx",
                  "purpose": "CM_ACCESS",
                  "authMode": "MOBILE_OTP",
                  "requester": {
                    "type": "PHR",
                    "id": ""
                  }
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given invalid mandatory field patientId for login phrAddress auth init should return 400 bad request")
    public void givenInvalidValueForMandatoryFieldPatientId_ShouldReturn400Error() throws Exception {
        String request = """
                {
                  "patientId": "hinsbx",
                  "purpose": "CM_ACCESS",
                  "authMode": "MOBILE_OTP",
                  "requester": {
                    "type": "PHR",
                    "id": "IN0400XX"
                  }
                }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-init")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }


//TC for/login/hid/search/auth-init ends
//TC for/login/hid/search/auth-confirm begins

    @Test
    @Description("To test given null request for login phraddress authConfirm should return 400 bad req")
    public void givenNullRequestForLoginPhrAuthConfirm_ShouldReturnBadReq() {
        Mono<AuthConfirmResponse> response = Mono.just(new AuthConfirmResponse());
        response.subscribe(res -> {
            res.getError().setErrorString("Request cannot be null");
            res.getError().setCode("400");
        });

        Assertions.assertThat(controller.verifyOtpPhrLogin(null, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
    }

    @Test
    @Description("To test that given null mandatory field transactionId for login phrAddress auth confirm should return 400 bad request")
    public void givenInvalidValueForMandatoryFieldTransactionId_ShouldReturn400Error() throws Exception {
        String request = """
                {
                   "transactionId": "",
                   "authCode": "2xxWA2g4HeLZsG3NB9/Zx676BIAXZaCHZU3LkrXxV0DSCaT1dQpKsd/Nq6tw6yjSOXiY8vM9GJpZ3gnkBttp47ciwVjM7iIKXKZghjuStDxIabUjEA5OdQZkLdiXp0t185s59tfOnKz1FsJeOPBzhM6qAEbn7EgMZounP3aZrS16FQrWahLNVgrxeVOrfg7HgZcwK+EHTP8q8Z9Ya4sW4sdsM3Aptkb1aBpj8j/G36+n9xNEoWTljfCeHdgpwKzWr2yU72ZLUXSEykA722H8NM8L982HNiLlOnBbmoaijMo50MKFse9pmSlveIQGPl3uz/NtAy+5sKLjtt31AR45sQ==",
                   "requesterId": "IN0400XX"
                 }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-confirm")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field authCode for login phrAddress auth confirm should return 400 bad request")
    public void givenInvalidValueForMandatoryFieldAuthCode_ShouldReturn400Error() throws Exception {
        String request = """
                {
                   "transactionId": "de277b66-00ea-4a4a-a29f-bb9a467960aa",
                   "authCode": "",
                   "requesterId": "IN0400XX"
                 }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-confirm")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null mandatory field requesterId for login phrAddress auth confirm should return 400 bad request")
    public void givenNullValueForMandatoryFieldRequesterIdForAuthConfirm_ShouldReturn400Error() throws Exception {
        String request = """
                {
                   "transactionId": "de277b66-00ea-4a4a-a29f-bb9a467960aa",
                   "authCode": "2xxWA2g4HeLZsG3NB9/Zx676BIAXZaCHZU3LkrXxV0DSCaT1dQpKsd/Nq6tw6yjSOXiY8vM9GJpZ3gnkBttp47ciwVjM7iIKXKZghjuStDxIabUjEA5OdQZkLdiXp0t185s59tfOnKz1FsJeOPBzhM6qAEbn7EgMZounP3aZrS16FQrWahLNVgrxeVOrfg7HgZcwK+EHTP8q8Z9Ya4sW4sdsM3Aptkb1aBpj8j/G36+n9xNEoWTljfCeHdgpwKzWr2yU72ZLUXSEykA722H8NM8L982HNiLlOnBbmoaijMo50MKFse9pmSlveIQGPl3uz/NtAy+5sKLjtt31AR45sQ==",
                   "requesterId": ""
                 }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-confirm")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given null for all mandatory fields for login phrAddress auth confirm should return 400 bad request")
    public void givenNullValueForAllMandatoryFields_ShouldReturn400Error() throws Exception {
        String request = """
                {
                   "transactionId": "",
                   "authCode": "",
                   "requesterId": ""
                 }
                """;

        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/phrAddress/auth-confirm")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(request))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    //TC for/login/hid/search/auth-confirm ends
//TC /login/phrAddress/search/auth-mode begins
    @Test
    @Description("To test that given null for mandatory request param phrAddress for login phrAddress search authMode should return 400 bad request")
    public void givenNullValueForRequestParamPhrAddress_ShouldReturn400Error() throws Exception {
        String phrAddress = "abc1sbx";
        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.get("/api/v1/login/phrAddress/search/auth-mode")
                        .param("phrAddress", ""))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }

    @Test
    @Description("To test that given Invalid for mandatory request param phrAddress for login phrAddress search authMode should return 400 bad request")
    public void givenInvalidValueForRequestParamPhrAddress_ShouldReturn400Error() throws Exception {
        String phrAddress = "abc1sbx";
        mockMvc = MockMvcBuilders
                .standaloneSetup(controller).build();
        mockMvc.perform(MockMvcRequestBuilders.get("/api/v1/login/phrAddress/search/auth-mode")
                        .param("phrAddress", phrAddress))
                .andExpect(MockMvcResultMatchers.status().isBadRequest());
    }


//TC /login/phrAddress/search/auth-mode ends


    @AfterEach
    void tearDown() {
    }
}