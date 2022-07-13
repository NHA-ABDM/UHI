package in.gov.abdm.eua.userManagement.controller;

import in.gov.abdm.eua.userManagement.constants.ConstantsUtils;
import in.gov.abdm.eua.userManagement.dto.phr.*;
import in.gov.abdm.eua.userManagement.dto.phr.login.LoginViaMobileEmailRequestInit;
import in.gov.abdm.eua.userManagement.exceptions.PhrException400;
import in.gov.abdm.eua.userManagement.exceptions.PhrException500;
import in.gov.abdm.eua.userManagement.service.impl.UserServiceImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.hibernate.service.spi.ServiceException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.validation.Valid;
import java.util.Set;

@Tag(name = "Login and Registration using mobile and email", description = "These APIs are intended to be used for user registration and login to EUA using mobile and email. These APIs are using PHR's APIs internally")
@RestController
@RequestMapping("api/v1/user")
public class PhrLoginAndRegistrationUsingMobileEmailController {
    private static final Logger LOGGER = LoggerFactory.getLogger(PhrLoginAndRegistrationUsingMobileEmailController.class);
    private final WebClient webClient;

    @Value("${abha.base.url}")
    private String abhaBaseUrl;

    @Value("${abdm.wrapper.url}")
    private String wrapperUrl;
    @Value("${abdm.phr.generateOtp.url}")
    private String generateOtpUrl;
    @Value("${abdm.phr.resendOtp.url}")
    private String resendOtpUrl;
    @Value("${abdm.phr.validateOtp.url}")
    private String validateOtpUrl;
    @Value("${abdm.phr.register.url}")
    private String registerUrl;
    @Value("${abdm.phr.registerAdditional.url}")
    private String registerAdditional;

    @Value("${abdm.phr.login.mobileEmail.authInit.url}")
    private String loginMobileEmailAuthInitUrl;
    @Value("${abdm.phr.login.mobileEmail.authConfirm.url}")
    private String loginMobileEmailAuthConfirmUrl;
    @Value("${abdm.phr.login.mobileEmail.preVerify.url}")
    private String loginMobileEmailPreVerifyUrl;

    private final UserServiceImpl userService;


    public PhrLoginAndRegistrationUsingMobileEmailController(WebClient webClient, UserServiceImpl userService) {
        this.webClient = webClient;
        this.userService = userService;
    }

    @PostMapping("/registration/mobileEmail/generate/otp")
    @Operation(
            summary = "Registration API generating OTP",
            description = "Generate OTP for registration using Mobile or Email",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = TransactionResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<TransactionResponse>> generateOtp(@RequestBody GenerateOTPRequest otpDTO) {
        LOGGER.info("Inside /registration/mobileEmail/generate/otp API ");

        TransactionResponse BAD_REQUEST = applyValidationsForGenerateOtp(otpDTO);
        if (BAD_REQUEST != null) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(BAD_REQUEST));

        Mono<TransactionResponse> sessionIdMono;
            sessionIdMono = this.webClient
                    .post()
                    .uri(wrapperUrl + generateOtpUrl)
                    .body(BodyInserters.fromValue(otpDTO))
                    .retrieve()
                    .onStatus(HttpStatus::is4xxClientError,
                            response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                    .onStatus(HttpStatus::is5xxServerError,
                            response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                    .bodyToMono(TransactionResponse.class)
                    .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(sessionIdMono);
    }


    @PostMapping("/registration/mobileEmail/validate/otp")
    @Operation(
            summary = "Registration API validating OTP",
            description = "Verify OTP for registration using Mobile or Email. OTP is valid only for " + ConstantsUtils.OTP_DURATION + " mins",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = TransactionResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<TransactionWithPHRResponse>> validateOtp(@RequestBody VerifyOTPRequest otpDTO) {
        LOGGER.info("Inside /registration/mobileEmail/validate/otp API ");

        TransactionWithPHRResponse BAD_REQUEST = applyValidationsForValidateOtp(otpDTO);
        if (BAD_REQUEST != null) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(BAD_REQUEST));

        Mono<TransactionWithPHRResponse> verifyDetails;
        verifyDetails = this.webClient.post().uri(wrapperUrl + validateOtpUrl).body(Mono.just(otpDTO), VerifyOTPRequest.class)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new ServiceException(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new ServiceException(error))))
                .bodyToMono(TransactionWithPHRResponse.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(verifyDetails);
    }

    private <T extends ServiceResponse> Mono<T> getErrorSchemaReady(Throwable error) {
        LOGGER.error("PhrLoginMobileEmailController::error::onErrorResume::" + error.getMessage());
        Mono<TransactionWithPHRResponse> errorMono = Mono.just(new TransactionWithPHRResponse());
        errorMono.subscribe(err -> {
            err.getError().setErrorString(error.getLocalizedMessage());
            err.getError().setCode("500");
            err.getError().setPath("/registration/mobileEmail/validate/otp");
        });
        return (Mono<T>) errorMono;
    }


    @GetMapping("/states")
    @Operation(
            summary = "Get All states",
            description = "Get all states along with their codes",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = Set.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<?>> getAllStates() {
        LOGGER.info("Inside /states API ");

        Mono<Set> statesEntityDTO;
        statesEntityDTO = webClient.get().uri(wrapperUrl + "/states")
                .retrieve()
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new ServiceException(error))))
                .bodyToMono(Set.class).onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.OK).body(statesEntityDTO);
    }

    @GetMapping("/{id}/districts")
    @Operation(
            summary = "Get Districts",
            description = "Find all districts along with their codes for a selected state",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = Set.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<?>> getAllDistricts(@PathVariable String id) {
        LOGGER.info("Inside \"/{id}/districts API ");

        if (id == null) {
            ServiceResponse errResponse = new ServiceResponse();
            errResponse.getError().setCode("400");
            errResponse.getError().setErrorString("District ID cannot be null");
            errResponse.getError().setPath("PhrLoginAndRegistrationUsingMobileAndEmailController/getAllDistricts");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(errResponse));
        }

        String url = wrapperUrl + "/" + id + "/districts";
        Mono<Set> statesEntityDTO;
        statesEntityDTO = webClient.get().uri(url)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new ServiceException(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(Set.class)
                .onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.OK).body(statesEntityDTO);
    }

    @PostMapping("/registration/mobileEmail/create/phrAddress/suggestion")
    @Operation(
            summary = "Gets PHR address suggestions",
            description = "Find PHR address suggestions based on given PHR address",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = SuggestionsDTO.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<SuggestionsDTO>> getSuggestions(@Valid @RequestBody ResendOTPRequest suggestionsRequest, Errors errors) {
        LOGGER.info("Inside /registration/mobileEmail/create/phrAddress/suggestion API ");

        if (errors.hasErrors()) {
            Mono<SuggestionsDTO> suggestions = Mono.just(new SuggestionsDTO());
            suggestions.subscribe(err -> {
                err.getError().setErrorString(errors.getAllErrors().toString());
                err.getError().setCode("400");
                err.getError().setPath(errors.getNestedPath());
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(suggestions);
        }

        Mono<SuggestionsDTO> suggestions;
        suggestions = webClient.post().uri(wrapperUrl + "/v1/apps/create/phrAddress/suggestion")
                .body(Mono.just(suggestionsRequest), ResendOTPRequest.class)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(SuggestionsDTO.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(suggestions);
    }

    @GetMapping("/registration/mobileEmail/phrAddress/isExist")
    @Operation(
            summary = "Checks if PHR address exists",
            description = "Validates if a specified PHR address already exists or not.",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = IsPhrAddressExistsDTO.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<IsPhrAddressExistsDTO>> isExists(@RequestParam String phrAddress) {

        LOGGER.info("Inside /registration/mobileEmail/phrAddress/isExist API ");

        Mono<IsPhrAddressExistsDTO> phrAddressExistsResponse;
        String queryParam = "?phrAddress=" + phrAddress;
        String url = wrapperUrl + "/v1/apps/phrAddress/isExist" + queryParam;
        phrAddressExistsResponse = webClient.get()
                .uri(url)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(IsPhrAddressExistsDTO.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(phrAddressExistsResponse);
    }


    @PostMapping("/registration/mobileEmail/resend/otp")
    @Operation(
            summary = "Resends OTP for registration",
            description = "Resends the OTP for registration process initiated using mobile and email.",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = SuccessResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<SuccessResponse>> resendOtp(@RequestBody ResendOTPRequest otpDTO) {

        LOGGER.info("Inside /registration/mobileEmail/resend/otp API ");

        SuccessResponse BAD_REQUEST = applyValiationsForResendOtp(otpDTO);
        if (BAD_REQUEST != null) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(BAD_REQUEST));

        Mono<SuccessResponse> verifyDetails;
        verifyDetails = this.webClient.post().uri(wrapperUrl + resendOtpUrl).body(Mono.just(otpDTO), ResendOTPRequest.class)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(SuccessResponse.class)
                .onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.OK).body(verifyDetails);
    }


    @PostMapping("/registration/mobileEmail/details")
    @Operation(
            summary = "Get User's details",
            description = "Gathers details specified by the user for creation of a new PHR address",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = TransactionResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<TransactionResponse>> registerNewPhr(@RequestBody RegistrationByMobileOrEmailRequest otpDTO) {

        LOGGER.info("Inside /registration/mobileEmail/details API ");

        Mono<TransactionResponse> verifyDetails;

        TransactionResponse BAD_REQUEST = applyValidationsForRegisterNewPhr(otpDTO);
        if (BAD_REQUEST != null) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(BAD_REQUEST));


        verifyDetails = this.webClient.post().uri(wrapperUrl + registerUrl).body(Mono.just(otpDTO), RegistrationByMobileOrEmailRequest.class)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(TransactionResponse.class)
                .onErrorResume(this::getErrorSchemaReady);
        return ResponseEntity.status(HttpStatus.OK).body(verifyDetails);

    }

    @PostMapping("/registration/mobileEmail/create/phrAddress")
    @Operation(
            summary = "Creates a new PHR address",
            description = "Creates a new PHR address after validation and getting all details from the user",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = JwtResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<JwtResponse>> registerPhr(@Valid @RequestBody CreatePHRRequest otpDTO, @RequestHeader("Authorization") String auth,
                                                         Errors errors) {

        LOGGER.info("Inside /registration/mobileEmail/create/phrAddress API ");

        if (auth == null) {
            Mono<JwtResponse> badRequest = Mono.just(new JwtResponse());
            badRequest.subscribe(err -> {
                err.getError().setErrorString("Authorization Header cannot be null");
                err.getError().setCode("400");
                err.getError().setPath("/registration/mobileEmail/create/phrAddress");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(badRequest);
        }

        if (errors.hasErrors()) {
            JwtResponse BAD_REQUEST = new JwtResponse();
            BAD_REQUEST.getError().setErrorString(errors.getAllErrors().toString());
            BAD_REQUEST.getError().setCode("400");
            BAD_REQUEST.getError().setPath("/registration/mobileEmail/create/phrAddress");

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(BAD_REQUEST));
        }

        JwtResponse BAD_REQUEST = applyValiationsForRegisterPhr(otpDTO);
        if (BAD_REQUEST != null) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Mono.just(BAD_REQUEST));
        Mono<JwtResponse> verifyDetails;
        Mono<TransactionIdAadhar> txnIdResponse;
        verifyDetails = this.webClient.post().uri(wrapperUrl + registerAdditional).body(Mono.just(otpDTO), CreatePHRRequest.class)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500((error)))))
                .bodyToMono(JwtResponse.class)
                .onErrorResume(this::getErrorSchemaReady);

        txnIdResponse = this.webClient.post().uri(abhaBaseUrl + "/v1/auth/init")
                .header("Authorization", auth)
                .body(BodyInserters.fromValue(new HealthIdNumber(otpDTO.getAuthMethod(), otpDTO.getHealthIdNumber())))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(TransactionIdAadhar.class)
                .onErrorResume(this::getErrorSchemaReady);


        Mono<JwtResponse> response = txnIdResponse.zipWith(verifyDetails, (x, y) -> new JwtResponse(y.getToken(), y.getExpiresIn(), y.getRefreshToken(), y.getExpiresIn(), y.getPhrAdress(), y.getFirstName(), x.getTxnId()));
        return ResponseEntity.status(HttpStatus.OK).body(response);

    }


    @PostMapping("/confirmWithAadhaarOtp")
    public ResponseEntity<Mono<XtokenSchema>> getXtokenAfterAadharValidation(@Valid @RequestBody OtpRequestForXToken request, @RequestHeader("Authorization") String auth,
                                                                             @RequestHeader("accept") String accept,
                                                                             @RequestHeader("Accept-Language") String acceptLang,
                                                                             @RequestHeader("Content-Type") String contentType,
                                                                             Errors errors) {
        if (errors.hasErrors()) {
            Mono<XtokenSchema> badRequest = Mono.just(new XtokenSchema());
            badRequest.subscribe(err -> {
                err.getError().setErrorString(errors.getAllErrors().toString());
                err.getError().setCode("400");
                err.getError().setPath("/confirmWithAadhaarOtp");
            });


            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(badRequest);
        }

        Mono<XtokenSchema> xtokenSchema;
        xtokenSchema = this.webClient.post().uri(abhaBaseUrl + "/v1/auth/confirmWithAadhaarOtp")
                .headers(httpHeaders -> {
                    httpHeaders.add("Authorization", auth);
                    httpHeaders.add("accept", accept);
                    httpHeaders.add("Accept-Languag", acceptLang);
                    httpHeaders.add("Content-Type", contentType);
                })
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(XtokenSchema.class)
                .onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(xtokenSchema);
    }


    @PostMapping("/login/mobileEmail/auth-confirm")
    @Operation(
            summary = "Validates OTP for login",
            description = "Verify's OTP for login process",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = JwtResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<LoginPostVerificationRequestResponse>> validateUserToken(@RequestBody @Valid LoginPostVerificationRequest otpDTO, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /login/mobileEmail/auth-confirm API ");

        if (otpDTO == null) {
            Mono<LoginPostVerificationRequestResponse> verifyErrorDetails = Mono.just(new LoginPostVerificationRequestResponse());
            verifyErrorDetails.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyErrorDetails);
        }
        Mono<LoginPostVerificationRequestResponse> verifyDetails = null;

        if (errors.hasErrors()) {
            verifyDetails = Mono.just(new LoginPostVerificationRequestResponse());
            verifyDetails.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyDetails);
        }

        verifyDetails = this.webClient.post().uri(wrapperUrl + loginMobileEmailAuthConfirmUrl)
                .header("Authorization", auth)
                .body(Mono.just(otpDTO), LoginPostVerificationRequest.class)
                .retrieve()

                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))

                .bodyToMono(LoginPostVerificationRequestResponse.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(verifyDetails);

    }

    @GetMapping("/getRefreshToken/{healthIdNo}")
    @Operation(
            summary = "Gets refreshtoken",
            description = "Gets user's refreshtoken based on the healthId number provided",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginPostVerificationRequestResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<LoginPostVerificationRequestResponse>> getRefreshToken(@PathVariable("healthIdNo") String healthIdNo) {
        if (healthIdNo == null) {
            Mono<LoginPostVerificationRequestResponse> responseMono = Mono.just(new LoginPostVerificationRequestResponse());
            responseMono.subscribe(err -> {
                err.getError().setErrorString("Request param healthIdNo cannot be null");
                err.getError().setCode("400");
                err.getError().setPath("/getRefreshToken/{healthIdNo}");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responseMono);
        }
        Mono<LoginPostVerificationRequestResponse> responseMono = Mono.just(new LoginPostVerificationRequestResponse());
        try {
            responseMono.subscribe(res -> {
                res.setToken(userService.getUserRefreshTokenFromAbhaNumber(healthIdNo));
            });
        } catch (PhrException400 e) {
            responseMono = Mono.just(new LoginPostVerificationRequestResponse());
            return returnServerError400(responseMono, e);
        } catch (PhrException500 e) {
            responseMono = Mono.just(new LoginPostVerificationRequestResponse());
            return returnServerError500(responseMono, e);
        }
        return ResponseEntity.status(HttpStatus.OK).body(responseMono);

    }


    @PostMapping(value = "/login/mobileEmail/auth-init", produces = {MediaType.APPLICATION_JSON_VALUE})
    @Operation(
            summary = "Login auth-init",
            description = "Generates OTP for the login process using mobile and email",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginViaMobileEmailRequestResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<LoginViaMobileEmailRequestResponse>> generateOtpForLogin(@Valid @RequestBody LoginViaMobileEmailRequestInit otpDTO, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /login/mobileEmail/auth-init API ");


        if (otpDTO == null) {
            Mono<LoginViaMobileEmailRequestResponse> verifyErrorDetails = Mono.just(new LoginViaMobileEmailRequestResponse());
            verifyErrorDetails.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyErrorDetails);
        }
        Mono<LoginViaMobileEmailRequestResponse> verifyDetails;
        if (errors.hasErrors()) {
            verifyDetails = Mono.just(new LoginViaMobileEmailRequestResponse());
            verifyDetails.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyDetails);
        }
        verifyDetails = this.webClient.post()
                .uri(wrapperUrl + loginMobileEmailAuthInitUrl)
                .header("Authorization", auth)
                .body(Mono.just(otpDTO), LoginViaMobileEmailRequest.class)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(LoginViaMobileEmailRequestResponse.class)
                .onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.OK).body(verifyDetails);
    }

    @PostMapping("/login/mobileEmail/pre-Verify")
    @Operation(
            summary = "Login verify",
            description = "Verifies the OTP for the login using mobile and email",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginPreVerificationResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<LoginPreVerificationResponse>> verifyUserOtp(@RequestBody @Valid LoginPreVerificationRequest otpDTO, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /login/mobileEmail/pre-Verify API ");


        if (otpDTO == null) {
            Mono<LoginPreVerificationResponse> verifyErrorDetails = Mono.just(new LoginPreVerificationResponse());
            verifyErrorDetails.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyErrorDetails);
        }
        Mono<LoginPreVerificationResponse> verifyDetails;
        if (errors.hasErrors()) {
            verifyDetails = Mono.just(new LoginPreVerificationResponse());
            verifyDetails.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());

            });
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyDetails);
        }

        verifyDetails = this.webClient.post().uri(wrapperUrl + loginMobileEmailPreVerifyUrl).body(Mono.just(otpDTO), LoginPreVerificationRequest.class)
                .header("Authorization", auth)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException400(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(LoginPreVerificationResponse.class)
                .onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.OK).body(verifyDetails);
    }


    private <T extends ServiceResponse> ResponseEntity<Mono<T>> returnServerError400(Mono<T> verifyDetails, ServiceException e) {
        LOGGER.error(e.getLocalizedMessage());
        verifyDetails.subscribe(res -> {
            res.getError().setErrorString(e.getMessage());
            res.getError().setCode("4XX");
        });

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyDetails);
    }

    private <T extends ServiceResponse> ResponseEntity<Mono<T>> returnServerError500(Mono<T> verifyDetails, ServiceException e) {
        LOGGER.error(e.getLocalizedMessage());
        verifyDetails.subscribe(res -> {
            res.getError().setErrorString(e.getMessage());
            res.getError().setCode("5XX");
        });

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(verifyDetails);
    }


    private TransactionResponse applyValidationsForGenerateOtp(GenerateOTPRequest otpDTO) {
        if (otpDTO == null) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Request cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getValue()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Mobile number cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getAuthMode()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("AuthMode cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        return null;
    }

    private TransactionWithPHRResponse applyValidationsForValidateOtp(VerifyOTPRequest otpDTO) {
        if (otpDTO == null) {
            TransactionWithPHRResponse errorResponse = new TransactionWithPHRResponse();
            errorResponse.getError().setErrorString("Request cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getValue()) {
            TransactionWithPHRResponse errorResponse = new TransactionWithPHRResponse();
            errorResponse.getError().setErrorString("OTP number cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getSessionId()) {
            TransactionWithPHRResponse errorResponse = new TransactionWithPHRResponse();
            errorResponse.getError().setErrorString("sessionId cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        return null;
    }

    private SuccessResponse applyValiationsForResendOtp(ResendOTPRequest otpDTO) {
        if (otpDTO == null) {
            SuccessResponse errorResponse = new SuccessResponse();
            errorResponse.getError().setErrorString("Request cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }

        if (null == otpDTO.getSessionId()) {
            SuccessResponse errorResponse = new SuccessResponse();
            errorResponse.getError().setErrorString("SessionId cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        return null;
    }

    private JwtResponse applyValiationsForRegisterPhr(CreatePHRRequest otpDTO) {
        if (otpDTO == null) {
            JwtResponse errorResponse = new JwtResponse();
            errorResponse.getError().setErrorString("Request cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getSessionId()) {
            JwtResponse errorResponse = new JwtResponse();
            errorResponse.getError().setErrorString("sessionId cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getPhrAddress()) {
            JwtResponse errorResponse = new JwtResponse();
            errorResponse.getError().setErrorString("PhrAddress cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        return null;
    }

    private TransactionResponse applyValidationsForRegisterNewPhr(RegistrationByMobileOrEmailRequest otpDTO) {
        if (otpDTO == null) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Request cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getSessionId()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("SessionId object cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getName()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Name object cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getName().getFirst() || null == otpDTO.getName().getMiddle() || null == otpDTO.getName().getLast()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Invalid First/Middle/Last name. Null provided");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getDateOfBirth()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Date of birth object cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getDateOfBirth().getDateOfBirth() || null == otpDTO.getDateOfBirth().getMonthOfBirth() || null == otpDTO.getDateOfBirth().getYearOfBirth()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Invalid Date of birth (Date/Month/Year). Null provided");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }

        if (null == otpDTO.getGender()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Gender cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getStateCode()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("StateCode cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }

        if (null == otpDTO.getDistrictCode()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("DistrictCode cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        if (null == otpDTO.getMobile()) {
            TransactionResponse errorResponse = new TransactionResponse();
            errorResponse.getError().setErrorString("Mobile cannot be Null");
            errorResponse.getError().setCode("400");
            return errorResponse;
        }
        return null;
    }


}
