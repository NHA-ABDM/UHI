package in.gov.abdm.eua.userManagement.controller;

import in.gov.abdm.eua.userManagement.constants.ConstantsUtils;
import in.gov.abdm.eua.userManagement.dto.phr.CreatePHRRequest;
import in.gov.abdm.eua.userManagement.dto.phr.*;
import in.gov.abdm.eua.userManagement.dto.phr.login.*;
import in.gov.abdm.eua.userManagement.dto.phr.registration.*;
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
import org.springframework.http.ResponseEntity;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.validation.Valid;

@Tag(name = "Login and Registration using HealthId number", description = "These APIs are intended to be used for user registration and login to EUA using ABHA number and PHR address. These APIs are using PHR's APIs internally")
@RestController
@RequestMapping("api/v1/user")
public class PhrLoginAndRegistrationUsingHidController {

    private static final Logger LOGGER = LoggerFactory.getLogger(PhrLoginAndRegistrationUsingHidController.class);


    private final WebClient webClient;

    @Value("${abdm.wrapper.url}")
    private String wrapperUrl;

    @Value("${abdm.phr.base.url}")
    private String baseUrlPhr;
    @Value("${abdm.phr.registration.hid.confirmInit.url}")
    private String registrationByHidConfirmInitUrl;
    @Value("${abdm.phr.registration.hid.createPhr.url}")
    private String registrationByHidCreatePhrUrl;
    @Value("${abdm.phr.registration.hid.authInit.url}")
    private String registrationByHidAuthInitUrl;
    @Value("${abdm.phr.registration.hid.authMode.url}")
    private String registrationByHidAuthModeUrl;
    @Value("${abdm.phr.login.hid.authInit.url}")
    private String loginByHidAuthInitUrl;
    @Value("${abdm.phr.login.hid.authMode.url}")
    private String loginByHidAuthModeUrl;
    @Value("${abdm.phr.login.phrAdress.authInit.url}")
    private String loginByPhrAuthInitUrl;
    @Value("${abdm.phr.login.phrAdress.authConfirm.url}")
    private String loginByPhrAuthConfirmUrl;
    @Value("${abdm.phr.login.phrAdress.authMode.url}")
    private String loginByPhrAuthModeUrl;
    @Value("${abdm.phr.login.resend.otp.url}")
    private String loginResendOtpUrl;

    private final UserServiceImpl userService;


    public PhrLoginAndRegistrationUsingHidController(WebClient webClient, UserServiceImpl userService) {
        this.webClient = webClient;
        this.userService = userService;
    }


    @PostMapping("/registration/hid/search/auth-mode")
    @Operation(
            summary = "Registration API for finding available authentication modes",
            description = "Finds all the user's authentication modes",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = SearchResponsePayLoad.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<SearchResponsePayLoad>> findUserByHealthId(@Valid @RequestBody SearchRequestPayLoad searchRequestPayLoad, Errors errors) {

        LOGGER.info("Inside /registration/hid/search/auth-mode API ");

        ResponseEntity<Mono<SearchResponsePayLoad>> BAD_REQUEST = checkForErrorCasesRegistrationHidAuthMode(searchRequestPayLoad, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;
        Mono<SearchResponsePayLoad> searchResponsePayLoad;

        searchResponsePayLoad = this.webClient.post().uri(baseUrlPhr + registrationByHidAuthModeUrl).body(BodyInserters.fromValue(searchRequestPayLoad))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(SearchResponsePayLoad.class)
                .onErrorResume(this::getErrorSchemaReady);


        return ResponseEntity.status(HttpStatus.OK).body(searchResponsePayLoad);
    }

    @PostMapping("/registration/hid/auth-init")
    @Operation(
            summary = "Initiate authentication for registration",
            description = "Commence the user authentication process and generate OTP",
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
    public ResponseEntity<Mono<TransactionResponse>> generateTransactionOtp(@Valid @RequestBody LoginViaMobileEmailRequestRegistration loginViaMobileEmailRequest, Errors errors) {

        LOGGER.info("Inside /registration/hid/auth-init API ");

        ResponseEntity<Mono<TransactionResponse>> BAD_REQUEST1 = checkForNullRequestAuthInit(loginViaMobileEmailRequest);
        if (BAD_REQUEST1 != null) return BAD_REQUEST1;
        ResponseEntity<Mono<TransactionResponse>> BAD_REQUEST = checkForErrorsInAuthInitReq(errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;
        Mono<TransactionResponse> transactionResponse;

        transactionResponse = this.webClient.post().uri(baseUrlPhr + registrationByHidAuthInitUrl).body(BodyInserters.fromValue(loginViaMobileEmailRequest))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(TransactionResponse.class)
                .onErrorResume(this::getErrorSchemaReady);
        return ResponseEntity.status(HttpStatus.OK).body(transactionResponse);
    }

    @PostMapping("/registration/hid/confirm-init")
    @Operation(
            summary = "Confirm authentication for registration",
            description = "Confirm the user authentication process and validate OTP",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = HidResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<HidResponse>> verifyUserOtp(@Valid @RequestBody LoginRequestPayload loginRequestPayload, Errors errors) {

        LOGGER.info("Inside /registration/hid/confirm-init API ");


        Mono<HidResponse> hidResponse;

        ResponseEntity<Mono<HidResponse>> BAD_REQUEST = checkForErrorCasesRegistrationHidAuthConfirm(loginRequestPayload, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;
        hidResponse = this.webClient.post().uri(baseUrlPhr + registrationByHidConfirmInitUrl).body(BodyInserters.fromValue(loginRequestPayload))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(HidResponse.class)
                .onErrorResume(this::getErrorSchemaReady)
                .doOnNext(userService::mapHidresponseToUserDto);

        return ResponseEntity.status(HttpStatus.OK).body(hidResponse);
    }

    @PostMapping("/registration/hid/create/phrAddress")
    @Operation(
            summary = "Create user's PHR address",
            description = "Creates user's new PHR address after validation process is done",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = JwtResponseHid.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<JwtResponseHid>> createPhrAddress(@Valid @RequestBody CreatePHRRequest createPHRRequest, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /registration/hid/create/phrAddress API ");

        Mono<JwtResponseHid> jwtResponse;
        ResponseEntity<Mono<JwtResponseHid>> BAD_REQUEST = checkForErrorCasesRegistrationHidCreatePhr(createPHRRequest, auth, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;

        jwtResponse = this.webClient.post().uri(baseUrlPhr + registrationByHidCreatePhrUrl).body(BodyInserters.fromValue(createPHRRequest))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(JwtResponseHid.class)
                .onErrorResume(this::getErrorSchemaReady)
                .doOnNext(res -> {
                    if (!createPHRRequest.getIsAlreadyExistedPHR() && res != null) {
                        userService.saveNewPhrAddress(createPHRRequest.getHealthIdNumber(), res.getPhrAdress().toString());
                    } else {
                        LOGGER.error("Error while fetching user data linked to Abha number");
                        throw new PhrException500("Error while fetching user data linked to Abha number");
                    }
                });

//        Mono<JwtResponseHid> response = txnIdResponse.zipWith(jwtResponse, (x, y) -> new JwtResponseHid( y.getPhrAdress(),y.getToken(), x.getTxnId()));

        return ResponseEntity.status(HttpStatus.OK).body(jwtResponse);
    }

    @PostMapping(value = "/login/hid/search/auth-mode")
    @Operation(
            summary = "Finds the Auth mode for login",
            description = "Lists all available authentication modes of a user Login",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = SearchResponsePayLoad.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<SearchResponsePayLoad>> searchUserByHealthIdForLogin(@Valid @RequestBody SearchByHealthIdNumberRequest byHealthIdNumberRequest, Errors errors) {

        LOGGER.info("Inside /login/hid/search/auth-mode API ");

        ResponseEntity<Mono<SearchResponsePayLoad>> BAD_REQUEST = checkForErrorCasesLoginHidAuthMode(byHealthIdNumberRequest, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;
        Mono<SearchResponsePayLoad> responsePayLoad;

        responsePayLoad = this.webClient.post()
                .uri(baseUrlPhr + loginByHidAuthModeUrl).body(BodyInserters.fromValue(byHealthIdNumberRequest))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(SearchResponsePayLoad.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(responsePayLoad);
    }

    @PostMapping("/login/hid/auth-init")
    @Operation(
            summary = "Initiate login for HealthId number",
            description = "Commence the user login for healthId number and generate OTP",
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
    public ResponseEntity<Mono<LoginViaMobileEmailRequestResponse>> generateOtpForHidLogin(@Valid @RequestBody LoginViaMobileEmailRequest viaMobileEmailRequest, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /login/hid/auth-init API ");


        ResponseEntity<Mono<LoginViaMobileEmailRequestResponse>> BAD_REQUEST = checkForErrorCasesLoginHidAuthInit(viaMobileEmailRequest, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;
        Mono<LoginViaMobileEmailRequestResponse> emailRequestResponse;
        String uri = baseUrlPhr + loginByHidAuthInitUrl;
        emailRequestResponse = this.webClient.post()
                .uri(uri).body(BodyInserters.fromValue(viaMobileEmailRequest))
                .header("Authorization", auth)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(LoginViaMobileEmailRequestResponse.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(emailRequestResponse);
    }

    @PostMapping("/login/phrAddress/auth-init")
    @Operation(
            summary = "Initiate login for PHR address",
            description = "Commence the user login process using PHR address and generate OTP",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = AuthInitResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<AuthInitResponse>> generateOtpPhrLogin(@Valid @RequestBody LoginViaPhrRequest loginViaPhrRequest, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /login/phrAddress/auth-init API ");

        Mono<AuthInitResponse> responsePayLoad;

        ResponseEntity<Mono<AuthInitResponse>> BAD_REQUEST = checkForErrorCasesLoginPhrAddressAuthInit(loginViaPhrRequest, auth, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;

        responsePayLoad = this.webClient.post().uri(baseUrlPhr + loginByPhrAuthInitUrl)
                .header("Authorization", auth)
                .body(BodyInserters.fromValue(loginViaPhrRequest))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(AuthInitResponse.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(responsePayLoad);
    }

    @PostMapping("/login/phrAddress/auth-confirm")
    @Operation(
            summary = "Confirms login for PHR address",
            description = "Validates the user's OTP for PHR address",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = AuthConfirmResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<AuthConfirmResponse>> verifyOtpPhrLogin(@Valid @RequestBody VerifyPasswordOtpLoginRequest passwordOtpLoginRequest, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /login/phrAddress/auth-confirm API ");

        Mono<AuthConfirmResponse> responsePayLoad;


        ResponseEntity<Mono<AuthConfirmResponse>> BAD_REQUEST = checkForErrorCasesLoginPhraddressAuthConfirm(passwordOtpLoginRequest, auth, errors);
        if (BAD_REQUEST != null) return BAD_REQUEST;

        responsePayLoad = this.webClient.post().uri(baseUrlPhr + loginByPhrAuthConfirmUrl)
                .header("Authorization", auth)
                .body(BodyInserters.fromValue(passwordOtpLoginRequest))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(AuthConfirmResponse.class)
                .onErrorResume(this::getErrorSchemaReady)
                .doOnNext(res -> {
                    if (res != null && !res.getToken().isBlank()) {
                        LoginPostVerificationRequest loginPostVerificationRequest = new LoginPostVerificationRequest();
                        loginPostVerificationRequest.setPatientId(passwordOtpLoginRequest.getPatientId());
                        userService.saveUserRefreshToken(res.getToken(), loginPostVerificationRequest);
                        loginPostVerificationRequest = null;
                    } else {
                        LOGGER.error("Error while user login. Either token is null or server is down");
                        throw new PhrException500("Error while logging in user. Either token is null or server is down");
                    }
                });
        return ResponseEntity.status(HttpStatus.OK).body(responsePayLoad);
    }

    @GetMapping("/login/phrAddress/search/auth-mode")
    @Operation(
            summary = "Finds Auth modes for PHR address login",
            description = "Lists all the available authentication modes for PHR address login",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = SearchPhrAuthResponse.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<SearchPhrAuthResponse>> findUserByHealthIdForPhrLogin(@RequestParam(name = "phrAddress") String phrAddress) {

        LOGGER.info("Inside /login/phrAddress/search/auth-mode API ");

        Mono<SearchPhrAuthResponse> responsePayLoad;

        ResponseEntity<Mono<SearchPhrAuthResponse>> BAD_REQUEST = checkForErrorCasesLoginPhrAddressAuthMode(phrAddress);
        if (BAD_REQUEST != null) return BAD_REQUEST;

        String uri = baseUrlPhr + loginByPhrAuthModeUrl + "?phrAddress=" + phrAddress;
        responsePayLoad = this.webClient.get().uri(uri)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(SearchPhrAuthResponse.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(responsePayLoad);
    }

    @PostMapping("/resend/login/otp")
    @Operation(
            summary = "Resends OTP",
            description = "A common API to for all login flow to retrigger OTP",
            responses = {
                    @ApiResponse(
                            description = "Success",
                            responseCode = "200",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginResendOtp.class))
                    ),
                    @ApiResponse(description = "Not found", responseCode = "404", content = @Content),
                    @ApiResponse(description = "Internal error", responseCode = "500", content = @Content)
            }
    )
    public ResponseEntity<Mono<LoginResendOtp>> loginResendOtp(@Valid @RequestBody LoginResendOtp loginResendOtp, @RequestHeader("Authorization") String auth, Errors errors) {

        LOGGER.info("Inside /resend/login/otp API ");

        Mono<LoginResendOtp> responsePayLoad = null;

        ResponseEntity<Mono<LoginResendOtp>> BAD_REQUEST = checkForErrorCasesLoginResendOtp(loginResendOtp, auth, errors, responsePayLoad);
        if (BAD_REQUEST != null) return BAD_REQUEST;


        String uri = baseUrlPhr + loginResendOtpUrl;
        responsePayLoad = this.webClient.post()
                .uri(uri)
                .body(BodyInserters.fromValue(loginResendOtp))
                .header("Authorization", auth)
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new PhrException500(error))))
                .bodyToMono(LoginResendOtp.class)
                .onErrorResume(this::getErrorSchemaReady);

        return ResponseEntity.status(HttpStatus.OK).body(responsePayLoad);
    }


    private ResponseEntity<Mono<TransactionResponse>> checkForNullRequestAuthInit(LoginViaMobileEmailRequestRegistration loginViaMobileEmailRequest) {
        if (loginViaMobileEmailRequest == null) {
            Mono<TransactionResponse> responsePayLoad = Mono.just(new TransactionResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        return null;
    }

    private ResponseEntity<Mono<TransactionResponse>> checkForErrorsInAuthInitReq(Errors errors) {
        Mono<TransactionResponse> transactionResponse;
        if (errors.hasErrors()) {
            transactionResponse = Mono.just(new TransactionResponse());
            transactionResponse.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(transactionResponse);
        }
        return null;
    }

    private ResponseEntity<Mono<JwtResponseHid>> checkForErrorCasesRegistrationHidCreatePhr(CreatePHRRequest createPHRRequest, String auth, Errors errors) {
        Mono<JwtResponseHid> jwtResponse;
        if (createPHRRequest == null) {
            Mono<JwtResponseHid> response = Mono.just(new JwtResponseHid());
            response.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });
            LOGGER.error("Bad Request-: Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        if (auth == null) {
            Mono<JwtResponseHid> response = Mono.just(new JwtResponseHid());
            response.subscribe(res -> {
                res.getError().setErrorString("Authorization header cannot be null");
                res.getError().setCode("400");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        if (errors.hasErrors()) {
            jwtResponse = Mono.just(new JwtResponseHid());
            jwtResponse.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(jwtResponse);
        }
        return null;
    }

    private ResponseEntity<Mono<LoginViaMobileEmailRequestResponse>> checkForErrorCasesLoginHidAuthInit(LoginViaMobileEmailRequest viaMobileEmailRequest, Errors errors) {
        Mono<LoginViaMobileEmailRequestResponse> emailRequestResponse;
        if (viaMobileEmailRequest == null) {
            Mono<LoginViaMobileEmailRequestResponse> response = Mono.just(new LoginViaMobileEmailRequestResponse());
            response.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });
            LOGGER.error("Bad Request-: Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        if (errors.hasErrors()) {
            emailRequestResponse = Mono.just(new LoginViaMobileEmailRequestResponse());
            emailRequestResponse.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(emailRequestResponse);
        }
        return null;
    }

    private ResponseEntity<Mono<AuthInitResponse>> checkForErrorCasesLoginPhrAddressAuthInit(LoginViaPhrRequest loginViaPhrRequest, String auth, Errors errors) {
        Mono<AuthInitResponse> responsePayLoad;
        if (loginViaPhrRequest == null) {
            responsePayLoad = Mono.just(new AuthInitResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString("Request cannot be null");
            });
            LOGGER.error("Bad Request-: Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        if (auth.isBlank()) {
            responsePayLoad = Mono.just(new AuthInitResponse());
            responsePayLoad.subscribe(err -> {
                err.getError().setErrorString("Invalid Authorization token");
                err.getError().setCode("400");
                err.getError().setPath("/login/phrAddress/auth-confirm");
            });
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        if (errors.hasErrors()) {
            responsePayLoad = Mono.just(new AuthInitResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        return null;
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

    private ResponseEntity<Mono<SearchResponsePayLoad>> checkForErrorCasesRegistrationHidAuthMode(SearchRequestPayLoad searchRequestPayLoad, Errors errors) {
        if (searchRequestPayLoad == null) {
            Mono<SearchResponsePayLoad> responsePayLoad = Mono.just(new SearchResponsePayLoad());
            responsePayLoad.subscribe(res -> {
                LOGGER.error("Request cannot be null");
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        Mono<SearchResponsePayLoad> searchResponsePayLoad;

        if (errors.hasErrors()) {
            searchResponsePayLoad = Mono.just(new SearchResponsePayLoad());
            searchResponsePayLoad.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(searchResponsePayLoad);
        }
        return null;
    }

    private ResponseEntity<Mono<HidResponse>> checkForErrorCasesRegistrationHidAuthConfirm(LoginRequestPayload loginRequestPayload, Errors errors) {
        Mono<HidResponse> hidResponse;
        if (loginRequestPayload == null) {
            hidResponse = Mono.just(new HidResponse());
            hidResponse.subscribe(res -> {
                res.getError().setErrorString("Request cannot be null");
                res.getError().setCode("400");
            });
            LOGGER.error("Bad Request Request cannot be null");
            LOGGER.error("Bad Request Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(hidResponse);
        }
        if (errors.hasErrors()) {
            hidResponse = Mono.just(new HidResponse());
            hidResponse.subscribe(res -> {
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setCode("400");
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(hidResponse);
        }
        return null;
    }

    private ResponseEntity<Mono<SearchResponsePayLoad>> checkForErrorCasesLoginHidAuthMode(SearchByHealthIdNumberRequest byHealthIdNumberRequest, Errors errors) {
        Mono<SearchResponsePayLoad> responsePayLoad;
        if (byHealthIdNumberRequest == null) {
            responsePayLoad = Mono.just(new SearchResponsePayLoad());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString("Request cannot be null");
            });
            LOGGER.error("Bad Request-: Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }

        if (errors.hasErrors()) {
            responsePayLoad = Mono.just(new SearchResponsePayLoad());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        return null;
    }

    private ResponseEntity<Mono<AuthConfirmResponse>> checkForErrorCasesLoginPhraddressAuthConfirm(VerifyPasswordOtpLoginRequest passwordOtpLoginRequest, String auth, Errors errors) {
        Mono<AuthConfirmResponse> responsePayLoad;

        if (auth.isBlank()) {
            Mono<AuthConfirmResponse> errorMono = Mono.just(new AuthConfirmResponse());
            errorMono.subscribe(err -> {
                err.getError().setErrorString("Invalid Authorization token");
                err.getError().setCode("400");
                err.getError().setPath("/login/phrAddress/auth-confirm");
            });
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorMono);
        }


        if (passwordOtpLoginRequest == null) {
            responsePayLoad = Mono.just(new AuthConfirmResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString("Request cannot be null");
            });
            LOGGER.error("Bad Request-: Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }

        if (errors.hasErrors()) {
            responsePayLoad = Mono.just(new AuthConfirmResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString(errors.getAllErrors().toString());
                res.getError().setPath(errors.getNestedPath());
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        return null;
    }

    private ResponseEntity<Mono<SearchPhrAuthResponse>> checkForErrorCasesLoginPhrAddressAuthMode(String phrAddress) {
        Mono<SearchPhrAuthResponse> responsePayLoad;
        if (phrAddress.isBlank()) {
            responsePayLoad = Mono.just(new SearchPhrAuthResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString("Mandatory request parameter phrAddress cannot be null");
            });
            LOGGER.error("Bad Request phrAddress request param is null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }


        if (!phrAddress.matches(ConstantsUtils.PHR_ADDRESS_PATTERN)) {
            responsePayLoad = Mono.just(new SearchPhrAuthResponse());
            responsePayLoad.subscribe(res -> {
                res.getError().setCode("400");
                res.getError().setErrorString("Mandatory request parameter phrAddress is invalid");
            });
            LOGGER.error("Bad Request Request param phrAddress is null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        return null;
    }

    private ResponseEntity<Mono<LoginResendOtp>> checkForErrorCasesLoginResendOtp(LoginResendOtp loginResendOtp, String auth, Errors errors, Mono<LoginResendOtp> responsePayLoad) {
        if (loginResendOtp == null) {
            Mono<LoginResendOtp> otpMono = Mono.just(new LoginResendOtp());
            otpMono.subscribe(err -> {
                err.getError().setErrorString("Request cannot be null");
                err.getError().setCode("400");
                err.getError().setPath("/resend/login/otp");
            });
            LOGGER.error("Bad Request-: Request cannot be null");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(otpMono);
        }

        if (auth.isBlank()) {
            Mono<LoginResendOtp> otpMono = Mono.just(new LoginResendOtp());
            otpMono.subscribe(err -> {
               err.getError().setErrorString("Invalid authorization token");
                err.getError().setCode("400");
                err.getError().setPath("/resend/login/otp");
            });
            LOGGER.error("Bad Request-: Invalid authorization token");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(otpMono);
        }

        if (errors.hasErrors()) {
            Mono<LoginResendOtp> errorMono = Mono.just(new LoginResendOtp());
            errorMono.subscribe(err -> {
                err.getError().setErrorString(errors.getAllErrors().toString());
                err.getError().setCode("400");
                err.getError().setPath("/resend/login/otp");
            });
            LOGGER.error("Bad Request " + errors.getAllErrors());
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responsePayLoad);
        }
        return null;
    }


    private <T extends ServiceResponse> ResponseEntity<Mono<T>> returnServerError400(Mono<T> verifyDetails, ServiceException e) {
        LOGGER.error(e.getLocalizedMessage());
        verifyDetails.subscribe(res -> {
            res.getError().setErrorString(e.getLocalizedMessage());
            res.getError().setCode("4XX");
        });
        LOGGER.error("Bad request from Server " + e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(verifyDetails);
    }

    private <T extends ServiceResponse> ResponseEntity<Mono<T>> returnServerError500(Mono<T> verifyDetails, ServiceException e) {
        LOGGER.error(e.getLocalizedMessage());
        verifyDetails.subscribe(res -> {
            res.getError().setErrorString(e.getLocalizedMessage());
            res.getError().setCode("5XX");
        });
        LOGGER.error("Error from Server " + e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(verifyDetails);
    }


}
