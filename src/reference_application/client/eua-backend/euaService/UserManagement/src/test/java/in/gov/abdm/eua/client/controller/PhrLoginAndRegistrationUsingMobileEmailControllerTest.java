//package in.gov.abdm.eua.client.controller;
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import in.gov.abdm.eua.userManagement.controller.PhrLoginAndRegistrationUsingMobileEmailController;
//import in.gov.abdm.eua.userManagement.dto.phr.*;
//import org.assertj.core.api.Assertions;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.MockitoAnnotations;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.context.annotation.Description;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.MediaType;
//import org.springframework.http.ResponseEntity;
//import org.springframework.test.web.servlet.MockMvc;
//import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
//import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
//import org.springframework.test.web.servlet.setup.MockMvcBuilders;
//import org.springframework.web.reactive.function.client.WebClient;
//import reactor.core.publisher.Mono;
//
//import java.io.IOException;
//
//public class PhrLoginAndRegistrationUsingMobileEmailControllerTest {
//
//    @Mock
//    WebClient webClient;
//    @Mock
//    WebClient.RequestBodyUriSpec requestBodyUriSpec;
//    @Mock
//    WebClient.RequestHeadersSpec requestHeadersSpec;
//    @Mock
//    WebClient.UriSpec uriSpec;
//    @Mock
//    WebClient.RequestBodySpec requestBodySpec;
//    @Mock
//    WebClient.ResponseSpec responseSpec;
//    @InjectMocks
//    PhrLoginAndRegistrationUsingMobileEmailController mobileEmailController;
//    GenerateOTPRequest otpDTO;
//
//    @Autowired
//    private MockMvc mockMvc;
//
//    private static ObjectMapper objectMapper;
//
//
////    public static MockWebServer mockBackEnd;
//
////    @BeforeAll
////    static void setUpBeforeAll() throws IOException {
////        mockBackEnd = new MockWebServer();
////        mockBackEnd.start();
////
////        objectMapper = new ObjectMapper();
////    }
//
//    @BeforeEach
//    public void setUp() throws IOException {
//
//        MockitoAnnotations.openMocks(this);
//        otpDTO = new GenerateOTPRequest("boHpUHCCMad3BmRuFetZ+Xz31igXr6kneFDO4IZY0UpUVm3ep8RmW+lO9PZju1pnmVX7GPV5PuindHhEiypCAXugqaX9bgKHbsZrSWQYae4tcLLwJ0qCpjG8AzRCQBFXZDvxH/+T9ebVNiksIicU7wsEBv7q+3Gxv9Z3gXd+qvx/o3fxV8UXGXRirMt7bNYVLyZocFWu3pqPI7lZDZg2y8bjexNzV3B7xXCLgzB9Iqdqib5gBsogZoONnNGJ9+JeFlTyq+r3szO4xuYhGEleSahyvcB3s4nsjEow0HOG9FCQ4so3E0CX6XXf++rUU82cji+5eX6Pa/61XOUmGjhWiA==", "MOBILE_OTP");
//        WebClient restClient = WebClient.create();
//
//    }
//
//
//    // Test cases for generateOtp begins --------
//    @Test
//    @Description(" To test that when provided empty/null request should return 400 bad-request error")
//    public void whenCalledGenerateOtpMethodOtpDtoValueShouldNotBeNull() {
//        otpDTO = null;
//        Mono<TransactionResponse> otpGenerateResponse = Mono.just(new TransactionResponse());
//        otpGenerateResponse.subscribe(res -> {
//            res.getError().setErrorString("Request cannot be Null");
//            res.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.generateOtp(otpDTO).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(otpGenerateResponse).toString());
//    }
//
//    @Test
//    @Description(" To test that when provided empty/null mobile number should return 400 bad-request error")
//    public void whenCalledGenerateOtpMethodMobileValueShouldNotBeNull() {
//        otpDTO.setValue(null);
//        Mono<TransactionResponse> otpGenerateResponse = Mono.just(new TransactionResponse());
//        otpGenerateResponse.subscribe(r -> {
//            r.getError().setErrorString("Mobile number cannot be Null");
//            r.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.generateOtp(otpDTO).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(otpGenerateResponse).toString());
//    }
//
//    @Test
//    @Description(" To test that when provided empty/null AuthMode number should return 400 bad-request error")
//    public void whenCalledGenerateOtpMethodAuthModeValueShouldNotBeNull() {
//        otpDTO.setAuthMode(null);
//        Mono<TransactionResponse> otpGenerateResponse = Mono.just(new TransactionResponse());
//        otpGenerateResponse.subscribe(r -> {
//            r.getError().setErrorString("AuthMode cannot be Null");
//            r.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.generateOtp(otpDTO).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(otpGenerateResponse).toString());
//    }
//
//    // Test cases for generateOtp ends --------
//    // Test cases for validateOtp() begins --------
//
//    @Test
//    @Description("To test when provided null request should return 400 bad-request error")
//    public void whenCalledvalidateOtpRequestShouldNotBeNull() {
//        VerifyOTPRequest verifyOTPRequest = null;
//        Mono<TransactionWithPHRResponse> response = Mono.just(new TransactionWithPHRResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("Request cannot be null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.validateOtp(verifyOTPRequest).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null OTP should return 400 bad-request error")
//    public void whenCalledValidateOtpShouldNotBeNull() {
//        VerifyOTPRequest verifyOTPRequest = new VerifyOTPRequest();
//        verifyOTPRequest.setValue(null);
//        verifyOTPRequest.setSessionId("348573ueu47464u");
//
//        Mono<TransactionWithPHRResponse> response = Mono.just(new TransactionWithPHRResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("OTP number cannot be null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.validateOtp(verifyOTPRequest).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null SessionId should return 400 bad-request error")
//    public void whenCalledValidateSessionIdShouldNotBeNull() {
//        VerifyOTPRequest verifyOTPRequest = new VerifyOTPRequest();
//        verifyOTPRequest.setValue("boHpUHCCMad3BmRuFetZ+Xz31igXr6kneFDO4IZY0UpUVm3ep8RmW+lO9PZju1pnmVX7GPV5PuindHhEiypCAXugqaX9bgKHbsZrSWQYae4tcLLwJ0qCpjG8AzRCQBFXZDvxH/+T9ebVNiksIicU7wsEBv7q+3Gxv9Z3gXd+qvx/o3fxV8UXGXRirMt7bNYVLyZocFWu3pqPI7lZDZg2y8bjexNzV3B7xXCLgzB9Iqdqib5gBsogZoONnNGJ9+JeFlTyq+r3szO4xuYhGEleSahyvcB3s4nsjEow0HOG9FCQ4so3E0CX6XXf++rUU82cji+5eX6Pa/61XOUmGjhWiA==");
//        verifyOTPRequest.setSessionId(null);
//
//        Mono<TransactionWithPHRResponse> response = Mono.just(new TransactionWithPHRResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("SessionId cannot be null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.validateOtp(verifyOTPRequest).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//// Test cases for validateOtp() ends --------
//// Test cases for resendOtp() begins --------
//
//    @Test
//    @Description("To test when provided null request should return 400 bad-request error")
//    public void whenCalledResendOtpRequestShouldNotBeNull() {
//        ResendOTPRequest request = null;
//        Mono<SuccessResponse> response = Mono.just(new SuccessResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("Request cannot be Null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.resendOtp(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//
//    }
//
//    @Test
//    @Description("To test when provided null SessionId should return 400 bad-request error")
//    public void whenCalledResendOtpSessionIdShouldNotBeNull() {
//        ResendOTPRequest request = new ResendOTPRequest(null);
//        Mono<SuccessResponse> response = Mono.just(new SuccessResponse());
//
//        response.subscribe(r -> {
//            r.getError().setErrorString("SessionId cannot be Null");
//            r.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.resendOtp(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//
//    }
//
//    // Test cases for resendOtp() ends --------
//// Test cases for registerPhr() begins --------
//    @Test
//    @Description("To test when provided null request should return 400 bad-request error")
//    public void whenCalledRegisterPhrRequestShouldNotBeNull() {
//        CreatePHRRequest verifyOTPRequest = null;
//        Mono<JwtResponse> response = Mono.just(new JwtResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("Request cannot be null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerPhr(verifyOTPRequest, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null sessionId should return 400 bad-request error")
//    public void whenCalledRegisterPhrSessionIdShouldNotBeNull() {
//        CreatePHRRequest verifyOTPRequest = new CreatePHRRequest();
//        verifyOTPRequest.setPassword("scsdc");
//        verifyOTPRequest.setPhrAddress("sdcsdcsdc");
//        verifyOTPRequest.setIsAlreadyExistedPHR(true);
//        Mono<JwtResponse> response = Mono.just(new JwtResponse());
//
//        response.subscribe(r -> {
//            r.getError().setErrorString("sessionId cannot be null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerPhr(verifyOTPRequest, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null phrAddress should return 400 bad-request error")
//    public void whenCalledRegisterPhrPhrAddressShouldNotBeNull() {
//        CreatePHRRequest verifyOTPRequest = new CreatePHRRequest();
//        verifyOTPRequest.setPassword("scsdc");
//        verifyOTPRequest.setSessionId("sdcsdcsdc");
//        verifyOTPRequest.setIsAlreadyExistedPHR(true);
//        Mono<JwtResponse> response = Mono.just(new JwtResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("phrAddress cannot be null");
//            r.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerPhr(verifyOTPRequest, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    // Test cases for registerPhr() ends --------
//    // Test cases for registerNewPhr() begins --------
//
//    @Test
//    @Description("To test when provided null request should return 400 bad-request error")
//    public void whenCalledregisterNewPhrRequestShouldNotBeNull() {
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(r -> {
//            r.getError().setErrorString("Request cannot be null");
//            r.getError().setCode("400");
//
//        });
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null sessionId should return 400 bad-request error")
//    public void whenCalledregisterNewPhrSessionIdShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest(null, new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), "anyString()", "anyString()", "anyString()", "anyString()", "anyString()", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("SessionId cannot be null");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null name should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrNameShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("acsd", null, new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), "anyString()", "anyString()", "anyString()", "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("Name cannot be null");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null DateOfBirth should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrDOBShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), null, "anyString()", "anyString()", "anyString()", "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("Date of birth object cannot be Null");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null First Name/ Last name/ middle name should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrNameFLMShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration(null, null, null), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), "anyString()", "anyString()", "anyString()", "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("Invalid First/Middle/Last name. Null provided");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null Date/Month/ year should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrDOB_DMYShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr(null, null, null), "anyString()", "anyString()", "anyString()", "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("Invalid Date of birth (Date/Month/Year). Null provided");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null gender should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrGenderShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), null, "anyString()", "anyString()", "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("Gender cannot be Null");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null stateCode should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrStateCodeShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), "anyString()", null, "anyString()", "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("StateCode cannot be Null");
//            res.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null DistrictCode should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrDistrictCodeShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), "anyString()", "anyString()", null, "anyString()", "anyString", "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("DistrictCode cannot be Null");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//
//    @Test
//    @Description("To test when provided null Mobile should return 400 bad-request error")
//    public void whenCalledRegisterNewPhrMobileShouldNotBeNull() {
//        RegistrationByMobileOrEmailRequest request = new RegistrationByMobileOrEmailRequest("any()", new RegistrationByMobileOrEmailRequest.NamePhrRegistration("", "", ""), new RegistrationByMobileOrEmailRequest.DateOfBirthRegistrationPhr("", "", ""), "anyString()", "anyString()", "anyString()", "anyString()", null, "anyString()", "anyString()", "anyString()");
//
//        Mono<TransactionResponse> response = Mono.just(new TransactionResponse());
//        response.subscribe(res -> {
//            res.getError().setErrorString("DistrictCode cannot be Null");
//            res.getError().setCode("400");
//        });
//
//
//        Assertions.assertThat(mobileEmailController.registerNewPhr(request).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response).toString());
//    }
//    // Test cases for registerNewPhr() ends --------
//
////    @Test
////    @Description("To test get states method")
////    public void testGetStates() {
////        Mockito.when(phrLoginAndRegistrationController.getAllStates()).thenReturn(any());
////        Assertions.assertThat(phrLoginAndRegistrationController.getAllStates()).isNotNull();
////    }
//
//
//    // Test cases for login auth-init() begins
//
//    @Test
//    @Description("To test that given null request should return 400 bad request")
//    public void givenNullRequestShouldReturn400Error() {
//        Mono<LoginViaMobileEmailRequestResponse> verifyErrorDetails = Mono.just(new LoginViaMobileEmailRequestResponse());
//        verifyErrorDetails.subscribe(res -> {
//            res.getError().setErrorString("Request cannot be null");
//            res.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.generateOtpForLogin(null, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyErrorDetails).toString());
//    }
//
//
//    @Test
//    @Description("To test that given null value should return 400 bad request")
//    public void givenNullValueShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "value": null,
//                  "purpose": "CM_ACCESS",
//                  "authMode": "MOBILE_OTP",
//                  "requester": {
//                    "type": "PHR",
//                    "id": "IN0400XX"
//                  }
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-init").contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null purpose should return 400 bad request")
//    public void givenNullPurposeShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "value": "yJ2hY5bc2g3P2pQyca/ER6VYQ8TGMj/VN42h9xkh/3jAwJQtZEspnhrtEKqwFXt1+8budi64CPlUEzbkwUsCotIOMm8idfSX+SQyb8VlqLxxIkAzGvmXjWrbQUNEUWnnJjzkIjweNmj8GJ2u0uRdrAGpBc1vMoMz5XD2SGfFttvmziTtucq5w2dOoAPOni4Bl7sfii3Qyo8Szl1/tXNnZbDZi8HH9Cpajno4pFiu6mQDVTkkyDHTqyo7Bv3IFpdNYiRDAZ1yh1cBOfufMy1gSZQetCwETFxdsOgw7JvKL/gEN+RAFKZF2oUriCsAkYYbxW1cfrqa/YRXUw0ho+n4Jw==",
//                  "purpose": null,
//                  "authMode": "MOBILE_OTP",
//                  "requester": {
//                    "type": "PHR",
//                    "id": "IN0400XX"
//                  }
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-init")
//                        .contentType(MediaType.APPLICATION_JSON_VALUE)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null AuthMode should return 400 bad request")
//    public void givenNullAuthModeShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "value": "yJ2hY5bc2g3P2pQyca/ER6VYQ8TGMj/VN42h9xkh/3jAwJQtZEspnhrtEKqwFXt1+8budi64CPlUEzbkwUsCotIOMm8idfSX+SQyb8VlqLxxIkAzGvmXjWrbQUNEUWnnJjzkIjweNmj8GJ2u0uRdrAGpBc1vMoMz5XD2SGfFttvmziTtucq5w2dOoAPOni4Bl7sfii3Qyo8Szl1/tXNnZbDZi8HH9Cpajno4pFiu6mQDVTkkyDHTqyo7Bv3IFpdNYiRDAZ1yh1cBOfufMy1gSZQetCwETFxdsOgw7JvKL/gEN+RAFKZF2oUriCsAkYYbxW1cfrqa/YRXUw0ho+n4Jw==",
//                  "purpose": "CM_ACCESS",
//                  "authMode": null,
//                  "requester": {
//                    "type": "PHR",
//                    "id": "IN0400XX"
//                  }
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-init").contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null Requester Type should return 400 bad request")
//    public void givenNullRequesterTypeShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "value": "yJ2hY5bc2g3P2pQyca/ER6VYQ8TGMj/VN42h9xkh/3jAwJQtZEspnhrtEKqwFXt1+8budi64CPlUEzbkwUsCotIOMm8idfSX+SQyb8VlqLxxIkAzGvmXjWrbQUNEUWnnJjzkIjweNmj8GJ2u0uRdrAGpBc1vMoMz5XD2SGfFttvmziTtucq5w2dOoAPOni4Bl7sfii3Qyo8Szl1/tXNnZbDZi8HH9Cpajno4pFiu6mQDVTkkyDHTqyo7Bv3IFpdNYiRDAZ1yh1cBOfufMy1gSZQetCwETFxdsOgw7JvKL/gEN+RAFKZF2oUriCsAkYYbxW1cfrqa/YRXUw0ho+n4Jw==",
//                  "purpose": "CM_ACCESS",
//                  "authMode": "MOBILE_OTP",
//                  "requester": {
//                    "type": null,
//                    "id": "IN0400XX"
//                  }
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-init").contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null Requester Id should return 400 bad request")
//    public void givenNullRequesterIdShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "value": "yJ2hY5bc2g3P2pQyca/ER6VYQ8TGMj/VN42h9xkh/3jAwJQtZEspnhrtEKqwFXt1+8budi64CPlUEzbkwUsCotIOMm8idfSX+SQyb8VlqLxxIkAzGvmXjWrbQUNEUWnnJjzkIjweNmj8GJ2u0uRdrAGpBc1vMoMz5XD2SGfFttvmziTtucq5w2dOoAPOni4Bl7sfii3Qyo8Szl1/tXNnZbDZi8HH9Cpajno4pFiu6mQDVTkkyDHTqyo7Bv3IFpdNYiRDAZ1yh1cBOfufMy1gSZQetCwETFxdsOgw7JvKL/gEN+RAFKZF2oUriCsAkYYbxW1cfrqa/YRXUw0ho+n4Jw==",
//                  "purpose": "CM_ACCESS",
//                  "authMode": "MOBILE_OTP",
//                  "requester": {
//                    "type": "PHR",
//                    "id": null
//                  }
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-init").contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null Requester should return 400 bad request")
//    public void givenNullRequesterShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "value": "yJ2hY5bc2g3P2pQyca/ER6VYQ8TGMj/VN42h9xkh/3jAwJQtZEspnhrtEKqwFXt1+8budi64CPlUEzbkwUsCotIOMm8idfSX+SQyb8VlqLxxIkAzGvmXjWrbQUNEUWnnJjzkIjweNmj8GJ2u0uRdrAGpBc1vMoMz5XD2SGfFttvmziTtucq5w2dOoAPOni4Bl7sfii3Qyo8Szl1/tXNnZbDZi8HH9Cpajno4pFiu6mQDVTkkyDHTqyo7Bv3IFpdNYiRDAZ1yh1cBOfufMy1gSZQetCwETFxdsOgw7JvKL/gEN+RAFKZF2oUriCsAkYYbxW1cfrqa/YRXUw0ho+n4Jw==",
//                  "purpose": "CM_ACCESS",
//                  "authMode": "MOBILE_OTP",
//                  "requester": null
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-init").contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    // Test cases for login auth-init() begins
//
//    @Test
//    @Description("To test that given null Requester should return 400 bad request")
//    public void givenNullRequestForAuthInitShouldReturn400Error() throws Exception {
//        Mono<LoginViaMobileEmailRequestResponse> verifyErrorDetails = Mono.just(new LoginViaMobileEmailRequestResponse());
//        verifyErrorDetails.subscribe(r -> {
//            r.getError().setErrorString("Request cannot be null");
//            r.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.generateOtpForLogin(null, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyErrorDetails).toString());
//
//    }
//
//    @Test
//    @Description("To test that given null transactionId should return 400 bad request")
//    public void givenNullTransactionIdShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "transactionId": null,
//                  "authcode": "tSCaVUjHwHiMVCokz7u3ogfop5r7ON5GmVY4rJNaQhoVAMlZl5lDqbb4vobfFMsQ1zO404gkWqPqLoDCdavx+JJ5pxprDpRo+PbeV44q51xr5OoNW2ITy9x6WM81KF9o7OnIU3FOGg09jqcJ/By3S8ICWxzJDKVwCJPehHtjhSFiy+mdWEjKkBTrEWJRTy3ZOkij+fskm+JjLoJlIF0TmA94Jb/avX0/LrnacpWEYWAHd0R/8/HIeITVNwG5hnsuRyIcIKKy7bEuYul8wJDD8RPBhL/gIAV4c5zDCb518o1MJGQtNg8Yf/zcROdaynWrBHIh2tacPrxmLHiZHD+BHQ==",
//                  "requesterId": "IN0410XX"
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/pre-Verify")
//                        .contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null authcode should return 400 bad request")
//    public void givenNullAuthcodeShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "transactionId": "a825f76b-0696-40f3-864c-5a3a5b389a83",
//                  "authcode": null,
//                  "requesterId": "IN0410XX"
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/pre-Verify")
//                        .contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null requesterId should return 400 bad request")
//    public void givenNullRequesterIdForAuthInit_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "transactionId": "a825f76b-0696-40f3-864c-5a3a5b389a83",
//                  "authcode": "tSCaVUjHwHiMVCokz7u3ogfop5r7ON5GmVY4rJNaQhoVAMlZl5lDqbb4vobfFMsQ1zO404gkWqPqLoDCdavx+JJ5pxprDpRo+PbeV44q51xr5OoNW2ITy9x6WM81KF9o7OnIU3FOGg09jqcJ/By3S8ICWxzJDKVwCJPehHtjhSFiy+mdWEjKkBTrEWJRTy3ZOkij+fskm+JjLoJlIF0TmA94Jb/avX0/LrnacpWEYWAHd0R/8/HIeITVNwG5hnsuRyIcIKKy7bEuYul8wJDD8RPBhL/gIAV4c5zDCb518o1MJGQtNg8Yf/zcROdaynWrBHIh2tacPrxmLHiZHD+BHQ==",
//                  "requesterId": null
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/pre-Verify")
//                        .contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    // Test cases for login auth-init() ends
//
//    //Tests cases for login validateUserToken() begins
//    @Test
//    @Description("To test that given null Request should return 400 bad request")
//    public void givenNullRequestForPreVerifyShouldReturn400Error() throws Exception {
//        Mono<LoginPostVerificationRequestResponse> verifyErrorDetails = Mono.just(new LoginPostVerificationRequestResponse());
//        verifyErrorDetails.subscribe(res -> {
//            res.getError().setErrorString("Request cannot be null");
//            res.getError().setCode("400");
//        });
//
//        Assertions.assertThat(mobileEmailController.validateUserToken(null, null, null).toString()).isEqualTo(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyErrorDetails).toString());
//    }
//
//    @Test
//    @Description("To test that given null transactionId should return 400 bad request")
//    public void givenNullTransactionIdForAuthInit_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "transactionId": null,
//                  "authcode": "tSCaVUjHwHiMVCokz7u3ogfop5r7ON5GmVY4rJNaQhoVAMlZl5lDqbb4vobfFMsQ1zO404gkWqPqLoDCdavx+JJ5pxprDpRo+PbeV44q51xr5OoNW2ITy9x6WM81KF9o7OnIU3FOGg09jqcJ/By3S8ICWxzJDKVwCJPehHtjhSFiy+mdWEjKkBTrEWJRTy3ZOkij+fskm+JjLoJlIF0TmA94Jb/avX0/LrnacpWEYWAHd0R/8/HIeITVNwG5hnsuRyIcIKKy7bEuYul8wJDD8RPBhL/gIAV4c5zDCb518o1MJGQtNg8Yf/zcROdaynWrBHIh2tacPrxmLHiZHD+BHQ==",
//                  "requesterId": "IN0401XX"
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-confirm")
//                        .contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    @Test
//    @Description("To test that given null authcode should return 400 bad request")
//    public void givenNullAuthcodeForAuthInit_ShouldReturn400Error() throws Exception {
//        String request = """
//                {
//                  "transactionId": "dsvdvdsvdsvsdefcszc",
//                  "authcode": null,
//                  "requesterId": "IN0401XX"
//                }
//                """;
//
//        mockMvc = MockMvcBuilders
//                .standaloneSetup(mobileEmailController).build();
//        mockMvc.perform(MockMvcRequestBuilders.post("/api/v1/login/mobileEmail/auth-confirm")
//                        .contentType(MediaType.APPLICATION_JSON)
//                        .content(request))
//                .andExpect(MockMvcResultMatchers.status().isBadRequest());
//    }
//
//    //Tests cases for login validateUserToken() ends
//    //TC for /states begins
//
////    @Test
////    @Description("To test that given null authcode should return 400 bad request")
////    public void whenCalledStatesApi_ShouldReturnAllStates() throws Exception {
////        String baseUrl = String.format("http://localhost:%s",
////                mockBackEnd.getPort());
////
////        Set<StatesEntityDTO> statesEntityDTO = objectMapper.readValue("""
////                [
////                    {
////                        "stateName": "Andaman And Nicobar Islands",
////                        "stateCode": "35"
////                    },
////                    {
////                        "stateName": "Andhra Pradesh",
////                        "stateCode": "28"
////                    },
////                    {
////                        "stateName": "Arunachal Pradesh",
////                        "stateCode": "12"
////                    },
////                    {
////                        "stateName": "Assam",
////                        "stateCode": "18"
////                    },
////                    {
////                        "stateName": "Bihar",
////                        "stateCode": "10"
////                    },
////                    {
////                        "stateName": "Chandigarh",
////                        "stateCode": "4"
////                    },
////                    {
////                        "stateName": "Chhattisgarh",
////                        "stateCode": "22"
////                    },
////                    {
////                        "stateName": "Delhi",
////                        "stateCode": "7"
////                    },
////                    {
////                        "stateName": "Goa",
////                        "stateCode": "30"
////                    },
////                    {
////                        "stateName": "Gujarat",
////                        "stateCode": "24"
////                    },
////                    {
////                        "stateName": "Haryana",
////                        "stateCode": "6"
////                    },
////                    {
////                        "stateName": "Himachal Pradesh",
////                        "stateCode": "2"
////                    },
////                    {
////                        "stateName": "Jammu And Kashmir",
////                        "stateCode": "1"
////                    },
////                    {
////                        "stateName": "Jharkhand",
////                        "stateCode": "20"
////                    },
////                    {
////                        "stateName": "Karnataka",
////                        "stateCode": "29"
////                    },
////                    {
////                        "stateName": "Kerala",
////                        "stateCode": "32"
////                    },
////                    {
////                        "stateName": "Ladakh",
////                        "stateCode": "37"
////                    },
////                    {
////                        "stateName": "Lakshadweep",
////                        "stateCode": "31"
////                    },
////                    {
////                        "stateName": "Madhya Pradesh",
////                        "stateCode": "23"
////                    },
////                    {
////                        "stateName": "Maharashtra",
////                        "stateCode": "27"
////                    },
////                    {
////                        "stateName": "Manipur",
////                        "stateCode": "14"
////                    },
////                    {
////                        "stateName": "Meghalaya",
////                        "stateCode": "17"
////                    },
////                    {
////                        "stateName": "Mizoram",
////                        "stateCode": "15"
////                    },
////                    {
////                        "stateName": "Nagaland",
////                        "stateCode": "13"
////                    },
////                    {
////                        "stateName": "Odisha",
////                        "stateCode": "21"
////                    },
////                    {
////                        "stateName": "Puducherry",
////                        "stateCode": "34"
////                    },
////                    {
////                        "stateName": "Punjab",
////                        "stateCode": "3"
////                    },
////                    {
////                        "stateName": "Rajasthan",
////                        "stateCode": "8"
////                    },
////                    {
////                        "stateName": "Sikkim",
////                        "stateCode": "11"
////                    },
////                    {
////                        "stateName": "Tamil Nadu",
////                        "stateCode": "33"
////                    },
////                    {
////                        "stateName": "Telangana",
////                        "stateCode": "36"
////                    },
////                    {
////                        "stateName": "The Dadra And Nagar Haveli And Daman And Diu",
////                        "stateCode": "38"
////                    },
////                    {
////                        "stateName": "Tripura",
////                        "stateCode": "16"
////                    },
////                    {
////                        "stateName": "Uttar Pradesh",
////                        "stateCode": "9"
////                    },
////                    {
////                        "stateName": "Uttarakhand",
////                        "stateCode": "5"
////                    },
////                    {
////                        "stateName": "West Bengal",
////                        "stateCode": "19"
////                    }
////                ]""", Set.class);
////
////        mockBackEnd.enqueue(new MockResponse()
////                .setBody(objectMapper.writeValueAsString(statesEntityDTO))
////                .addHeader("Content-Type", "application/json"));
////
////        ResponseEntity<Mono<?>> allStates = mobileEmailController.getAllStates();
////
////        StepVerifier.create(Mono.just(allStates))
////                .expectNextMatches(res -> (res.getBody()!= null))
////                .verifyComplete();
////
////    }
//
//
//    //TC for /states ends
//
////    @AfterAll
////    static void tearDown() throws IOException {
////        mockBackEnd.shutdown();
////    }
//
//}