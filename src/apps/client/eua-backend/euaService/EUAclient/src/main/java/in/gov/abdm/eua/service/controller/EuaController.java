package in.gov.abdm.eua.service.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.service.constants.ConstantsUtils;
import in.gov.abdm.eua.service.constants.GlobalConstants;
import in.gov.abdm.eua.service.service.impl.EuaServiceImpl;
import in.gov.abdm.eua.service.service.impl.MQConsumerServiceImpl;
import in.gov.abdm.eua.service.utils.EuaUtility;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;

@Tag(name = "EUA service", description = "These APIs are intended to be used for service discovery and booking. Subsequent calls shall be redirected to UHI gateway and/or HSPA")
@RequestMapping("api/v1/euaService/")
@RestController
@Slf4j
public class EuaController {

    private static final Logger LOGGER = LoggerFactory.getLogger(EuaController.class);
    private final MQConsumerServiceImpl mqService;

    private final String abdmEUAURl;

    private final String bookignServiceUrl;

    private final EuaServiceImpl euaService;

    private final ObjectMapper objectMapper;

    @Autowired
    private EuaUtility euaUtility;

    public EuaController(EuaServiceImpl euaService, ObjectMapper objectMapper,
                         @Value("${spring.abdm_eua_url}")
                         String abdmEUAURl,
                         @Value("${spring.abdm_bookingService_url}")
                         String bookignServiceUrl,
                         @Value("${spring.abdm_gateway_url}")
                         String abdmGatewayUrl,
                         MQConsumerServiceImpl mqConsumerServiceImpl) {

        this.mqService = mqConsumerServiceImpl;

        this.euaService = euaService;
        this.objectMapper = objectMapper;

        this.abdmEUAURl = abdmEUAURl;
        this.bookignServiceUrl = bookignServiceUrl;


        LOGGER.info("EUA url {}", abdmEUAURl);
        LOGGER.info("Gateway url {}", abdmGatewayUrl);
        LOGGER.info("bookignServiceUrl {}", bookignServiceUrl);
    }


    @PostMapping(ConstantsUtils.ON_SEARCH_ENDPOINT)
    public ResponseEntity<Response> onSearch(@RequestBody String onSearchRequestString, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, NoSuchProviderException, InvalidKeyException {


        Request onSearchRequest = euaUtility.getEuaRequestBody(onSearchRequestString);
        String requestMessageId = onSearchRequest.getContext().getMessageId();
        headers.entrySet().forEach(h -> LOGGER.info(GlobalConstants.HEADER,requestMessageId, h));

        LOGGER.info("{} | Inside on_search API {}",requestMessageId, onSearchRequestString);


        LOGGER.info(GlobalConstants.REQUEST_BODY_LOG_STMT, onSearchRequest.getContext().getMessageId(), onSearchRequestString);
        String consumerId = onSearchRequest.getContext().getConsumerId();
        String action = onSearchRequest.getContext().getAction();

        euaService.verifyHeadersAndProceed(onSearchRequestString, headers, onSearchRequest, requestMessageId, consumerId, action);
        return euaService.getOnAckResponseResponseEntity(objectMapper, onSearchRequestString, "on_search", requestMessageId);
    }

    @PostMapping("/on_init")
    public ResponseEntity<Mono<String>> onInit(@RequestBody String onInitRequestString, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, NoSuchProviderException, InvalidKeyException {
        Request onInitRequest = euaUtility.getEuaRequestBody(onInitRequestString);

        String requestMessageId = onInitRequest.getContext().getMessageId();
        LOGGER.info("{} | Inside on_init API {}", requestMessageId, onInitRequestString);
        headers.entrySet().forEach(h -> LOGGER.info(GlobalConstants.HEADER,requestMessageId, h));

        LOGGER.info(GlobalConstants.REQUEST_BODY_LOG_STMT,onInitRequest.getContext().getMessageId(), onInitRequestString);
        String consumerId = onInitRequest.getContext().getConsumerId();
        String action = onInitRequest.getContext().getAction();

        euaService.verifyHeadersAndProceed(onInitRequestString, headers, onInitRequest, requestMessageId, consumerId, action);
        Mono<String> callToBookingService = mqService.webclientCallToPartnerOrGateway(onInitRequest, bookignServiceUrl, onInitRequestString,action ).doOnSuccess(res -> LOGGER.info(GlobalConstants.RESPONSE_FROM_BOOKING_SERVICE_LOG_STMT, requestMessageId,res));
        return ResponseEntity.status(HttpStatus.OK).body(callToBookingService);
    }

    @PostMapping("/on_confirm")
    public ResponseEntity<Mono<String>> onConfirm(@RequestBody String onConfirmRequestString, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, NoSuchProviderException, InvalidKeyException {
        LOGGER.info("Inside on_confirm API ");
        Request onConfirmRequest = euaUtility.getEuaRequestBody(onConfirmRequestString);
        String requestMessageId = onConfirmRequest.getContext().getMessageId();

        LOGGER.info(GlobalConstants.REQUEST_BODY_LOG_STMT, requestMessageId, onConfirmRequestString);
        headers.entrySet().forEach(h -> LOGGER.info(GlobalConstants.HEADER,requestMessageId, h));

        String consumerId = onConfirmRequest.getContext().getConsumerId();
        String action = onConfirmRequest.getContext().getAction();

        euaService.verifyHeadersAndProceed(onConfirmRequestString, headers, onConfirmRequest, requestMessageId, consumerId, action);
        Mono<String> callToBookingService = mqService.webclientCallToPartnerOrGateway(onConfirmRequest, bookignServiceUrl, onConfirmRequestString, action);
        callToBookingService.doOnNext(res -> LOGGER.info(GlobalConstants.RESPONSE_FROM_BOOKING_SERVICE_LOG_STMT, requestMessageId,res)).subscribe();

        return ResponseEntity.status(HttpStatus.OK).body(callToBookingService);

    }

    @PostMapping("/on_cancel")
    public ResponseEntity<Mono<String>> onCancel(@RequestBody String onCancelRequestString, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, NoSuchProviderException, InvalidKeyException {
        Request onCancelRequest = euaUtility.getEuaRequestBody(onCancelRequestString);
        String requestMessageId = onCancelRequest.getContext().getMessageId();

        LOGGER.info("{} | Inside on_cancel API {}", onCancelRequest.getContext().getMessageId(), onCancelRequestString);
        headers.entrySet().forEach(h -> LOGGER.info(GlobalConstants.HEADER,requestMessageId, h));

        LOGGER.info(GlobalConstants.REQUEST_BODY_LOG_STMT, onCancelRequest.getContext().getMessageId(), onCancelRequestString);
        String consumerId = onCancelRequest.getContext().getConsumerId();
        String action = onCancelRequest.getContext().getAction();

        euaService.verifyHeadersAndProceed(onCancelRequestString, headers, onCancelRequest, requestMessageId, consumerId, action);

        Mono<String> callToBookingService = mqService.webclientCallToPartnerOrGateway(onCancelRequest, bookignServiceUrl, onCancelRequestString, action);
        callToBookingService.doOnNext(res -> LOGGER.info(GlobalConstants.RESPONSE_FROM_BOOKING_SERVICE_LOG_STMT, requestMessageId,res)).subscribe();


        return ResponseEntity.status(HttpStatus.OK).body(callToBookingService);

    }

    @PostMapping("/on_status")
    public ResponseEntity<Response> onStatus(@RequestBody String onStatusRequestString, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, NoSuchProviderException, InvalidKeyException {
        Request onStatusRequest = euaUtility.getEuaRequestBody(onStatusRequestString);
        String requestMessageId = onStatusRequest.getContext().getMessageId();
        LOGGER.info("{} | Inside on_status API {}",onStatusRequest.getContext().getMessageId(), onStatusRequest);
        headers.entrySet().forEach(h -> LOGGER.info(GlobalConstants.HEADER,requestMessageId, h));

        LOGGER.info(GlobalConstants.REQUEST_BODY_LOG_STMT, onStatusRequest.getContext().getMessageId(), onStatusRequestString);
        String consumerId = onStatusRequest.getContext().getConsumerId();
        String action = onStatusRequest.getContext().getAction();
        euaService.verifyHeadersAndProceed(onStatusRequestString, headers, onStatusRequest, requestMessageId, consumerId, action);
        Mono<String> callToBookingService = mqService.webclientCallToPartnerOrGateway(onStatusRequest, bookignServiceUrl, onStatusRequestString, action);
        callToBookingService.doOnNext(res -> LOGGER.info(GlobalConstants.RESPONSE_FROM_BOOKING_SERVICE_LOG_STMT, requestMessageId,res)).subscribe();

        return euaService.getOnAckResponseResponseEntity(objectMapper, onStatusRequestString, "on_status", requestMessageId);
    }


    @PostMapping("/on_message")
    public ResponseEntity<Response> onMessage(@RequestBody String onMessageRequestString, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, NoSuchProviderException, InvalidKeyException {
        String requestMessageId = null;
        Request messageRequest = euaUtility.getEuaRequestBody(onMessageRequestString);
        messageRequest.getContext().setConsumerUri(abdmEUAURl);
        String providerURI = messageRequest.getContext().getProviderUri();
        requestMessageId = messageRequest.getContext().getMessageId();
        String consumerId = messageRequest.getContext().getConsumerId();
        String action = messageRequest.getContext().getAction();


        String finalRequestMessageId = requestMessageId;
        headers.entrySet().forEach(h -> LOGGER.info(GlobalConstants.HEADER, finalRequestMessageId, h));

        LOGGER.info("{} | Inside on_message API {}", requestMessageId, onMessageRequestString);

        LOGGER.info(GlobalConstants.PROVIDER_URI_LOG_STMT, providerURI);

        euaService.verifyHeadersAndProceed(onMessageRequestString, headers, messageRequest, requestMessageId, consumerId, action);
        Mono<String> callToBookingService = mqService.webclientCallToPartnerOrGateway(messageRequest, bookignServiceUrl, onMessageRequestString, action);
        String finalRequestMessageId1 = requestMessageId;
        callToBookingService.doOnNext(res -> LOGGER.info(GlobalConstants.RESPONSE_FROM_BOOKING_SERVICE_LOG_STMT, finalRequestMessageId1,res)).subscribe();
        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT, requestMessageId, onMessageRequestString);

        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }

    @PostMapping(ConstantsUtils.SEARCH_ENDPOINT)
    public ResponseEntity<Response> search(@RequestBody String searchRequestString,  @RequestHeader Map<String, String> headers) throws JsonProcessingException {
        String requestMessageId = null;
        Request searchRequest = euaUtility.getEuaRequestBody(searchRequestString);
        String publicKeyId = "";

        LOGGER.info(" {} | Inside Search API :: {}", searchRequest.getContext().getMessageId(), searchRequestString);


        searchRequest.getContext().setConsumerUri(abdmEUAURl);
        requestMessageId = searchRequest.getContext().getMessageId();
        String clientId = searchRequest.getContext().getConsumerId();
        String action = searchRequest.getContext().getAction();
        String domain = searchRequest.getContext().getDomain();
        String request = objectMapper.writeValueAsString(searchRequest);

        LOGGER.info(GlobalConstants.REQUEST_BODY_LOG_STMT,requestMessageId,searchRequestString);
        mqService.pushToMq(request, clientId, action, requestMessageId);
        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT,searchRequest.getContext().getMessageId(), searchRequestString);
        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }


    @PostMapping("/init")
    public ResponseEntity<Response> init(@RequestBody String initRequestString) throws JsonProcessingException {

        String url;

        String requestMessageId = null;
        Request initRequest = euaUtility.getEuaRequestBody(initRequestString);
        LOGGER.info("{} | Inside init API {},", initRequest.getContext().getMessageId(), initRequestString);


        initRequest.getContext().setConsumerUri(abdmEUAURl);
        String providerURI = initRequest.getContext().getProviderUri();
        requestMessageId = initRequest.getContext().getMessageId();
        String clientId = initRequest.getContext().getConsumerId();
        String action = initRequest.getContext().getAction();

        String request = objectMapper.writeValueAsString(initRequest);

        LOGGER.info(GlobalConstants.PROVIDER_URI_LOG_STMT, providerURI);
        mqService.pushToMq(request, clientId, action, requestMessageId);
        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT, requestMessageId, initRequestString);
        url = providerURI + ConstantsUtils.INIT_ENDPOINT;
        initRequest.getContext().setProviderUri(url);
        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }

    @PostMapping("/confirm")
    public ResponseEntity<Response> confirm(@RequestBody String confirmRequestString) throws JsonProcessingException {


        String requestMessageId = null;
        Request confirmRequest = euaUtility.getEuaRequestBody(confirmRequestString);
        confirmRequest.getContext().setConsumerUri(abdmEUAURl);
        String providerURI = confirmRequest.getContext().getProviderUri();
        requestMessageId = confirmRequest.getContext().getMessageId();
        String clientId = confirmRequest.getContext().getConsumerId();
        String action = confirmRequest.getContext().getAction();

        String request = objectMapper.writeValueAsString(confirmRequest);


        LOGGER.info(" {} | Inside confirm API {}",requestMessageId, confirmRequestString);

        LOGGER.info(GlobalConstants.PROVIDER_URI_LOG_STMT, providerURI);

        mqService.pushToMq(request, clientId, action, requestMessageId);

        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT, requestMessageId, confirmRequestString);
        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }

    @PostMapping("/status")
    public ResponseEntity<Response> status(@RequestBody String statusRequestString) throws JsonProcessingException {
        String requestMessageId = null;

        Request statusRequest = euaUtility.getEuaRequestBody(statusRequestString);

        statusRequest.getContext().setConsumerUri(abdmEUAURl);
        String providerURI = statusRequest.getContext().getProviderUri();
        requestMessageId = statusRequest.getContext().getMessageId();
        String clientId = statusRequest.getContext().getConsumerId();
        String action = statusRequest.getContext().getAction();

        String request = objectMapper.writeValueAsString(statusRequest);

        LOGGER.info(" {} | Inside status API {} ",requestMessageId,statusRequestString );

        LOGGER.info(GlobalConstants.PROVIDER_URI_LOG_STMT, providerURI);
        mqService.pushToMq(request, clientId, action, requestMessageId);

        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT, requestMessageId, statusRequestString);
        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }

    @PostMapping("/cancel")
    public ResponseEntity<Response> cancel(@RequestBody String cancelRequestString) throws JsonProcessingException {
        String requestMessageId = null;
        Request cancelRequest = euaUtility.getEuaRequestBody(cancelRequestString);

        cancelRequest.getContext().setConsumerUri(abdmEUAURl);
        String providerURI = cancelRequest.getContext().getProviderUri();
        requestMessageId = cancelRequest.getContext().getMessageId();
        String clientId = cancelRequest.getContext().getConsumerId();
        String action = cancelRequest.getContext().getAction();

        String request = objectMapper.writeValueAsString(cancelRequest);

        LOGGER.info("{} | Inside cancel API {}", requestMessageId,cancelRequestString);
        LOGGER.info(GlobalConstants.PROVIDER_URI_LOG_STMT, providerURI);
        mqService.pushToMq(request, clientId, action, requestMessageId);
        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT, requestMessageId, cancelRequestString);
        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }


    @PostMapping("/message")
    public ResponseEntity<Response> message(@RequestBody String cancelRequestString) throws JsonProcessingException {
        String requestMessageId = null;
        Request messageRequest = euaUtility.getEuaRequestBody(cancelRequestString);

        messageRequest.getContext().setConsumerUri(abdmEUAURl);
        String providerURI = messageRequest.getContext().getProviderUri();
        requestMessageId = messageRequest.getContext().getMessageId();
        String clientId = messageRequest.getContext().getConsumerId();
        messageRequest.getContext().setAction(ConstantsUtils.ON_MESSAGE_ENDPOINT);
        String request = objectMapper.writeValueAsString(messageRequest);

        LOGGER.info("{} | Inside message API {}", requestMessageId, cancelRequestString);
        LOGGER.info(GlobalConstants.PROVIDER_URI_LOG_STMT, providerURI);

        mqService.pushToMq(request, clientId, GlobalConstants.MESSAGE, requestMessageId);
        LOGGER.info(GlobalConstants.REQUEST_BODY_ENQUEUED_LOG_STMT, requestMessageId, cancelRequestString);

        return ResponseEntity.status(HttpStatus.OK).body(EuaServiceImpl.generateAck());
    }

}
