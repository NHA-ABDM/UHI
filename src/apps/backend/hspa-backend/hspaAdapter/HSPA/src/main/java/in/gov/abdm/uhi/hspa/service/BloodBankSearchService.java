package in.gov.abdm.uhi.hspa.service;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.common.dto.Provider;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class BloodBankSearchService implements IService {

    @Value("${spring.gateway_uri}")
    String GATEWAY_URI;
    @Value("${spring.bloodbank.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.bloodbank.provider_id}")
    String PROVIDER_ID;
    @Autowired
    WebClient euaWebClient;

    @Value("${spring.gateway.publicKey}")
    String GATEWAY_PUBLIC_KEY;

    @Value("${spring.hspa.bloodbank.subsId}")
    String HSPA_SUBS_ID;

    @Value("${spring.hspa.bloodbank.privKey}")
    String HSPA_PRIV_KEY;

    @Value("${spring.hspa.bloodbank.pubKeyId}")
    String HSPA_PUBKEY_ID;

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    @Autowired
    WebClient webClient;

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    HspaUtility hspaUtility;

    @Autowired
    Crypt crypt;

    public static String getParsedDate(String date) throws ParseException {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(ConstantsUtils.DATE_TIME_PATTERN);
        Date dateParsed = null;
        dateParsed = simpleDateFormat.parse(date);

        return simpleDateFormat.format(dateParsed);
    }

    @Override
    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {

        Request objRequest = null;
        objRequest = objectMapper.readValue(request, Request.class);
        if (Boolean.parseBoolean(isHeaderEnabled)) {
            return processSearchWithHeaderVerification(request, headers, objRequest);
        } else {
            return processSearch(request, objRequest, objRequest);
        }
    }

    private Mono<Response> processSearchWithHeaderVerification(String request, Map<String, String> headers, Request objRequest) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException, SignatureException, InvalidKeyException, UserException {
        hspaUtility.checkXGatewayHeader(headers, objRequest);

        boolean isHeaderVerified = hspaUtility.getHeaderVerificationResult(request, headers, objRequest, GlobalConstants.X_GATEWAY_AUTHORIZATION.toLowerCase(), GATEWAY_PUBLIC_KEY);
        if (isHeaderVerified) {
            log.info("Processing::Search::Request:: {}.. Message Id is {}", request, CommonService.getMessageId(objRequest));
            if (CommonService.isTestHspaProviderSearchOrDoctorSearch(objRequest, false)) {
                return processSearch(request, objRequest, objRequest);
            } else {
                log.error(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, CommonService.getMessageId(objRequest));
                throw new HspaException("Invalid search Schema");
            }
        } else {
            log.error("{} | SearchService::processor::Header verification failed", objRequest.getContext().getMessageId());
            return Mono.error(new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage()));
        }
    }

    private Mono<Response> processSearch(String request, Request objRequest, Request finalObjRequest) {
        return runBloodBank(objRequest, request)
                .flatMap(result -> {
                    try {
                        callOnSearch(result).subscribe();
                    } catch (JsonProcessingException | NoSuchAlgorithmException | NoSuchProviderException |
                             InvalidKeySpecException e) {
                        log.error("{} | {}::processor::error::{}", finalObjRequest.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                        return Mono.error(new InvalidKeyException(GatewayError.INVALID_KEY.getMessage()));
                    } catch (Exception e) {
                        log.error("{} | {}::processor::error::{}", finalObjRequest.getContext().getMessageId(), this.getClass().getName(), e.getMessage());
                        return Mono.error(new HspaException(GatewayError.INTERNAL_SERVER_ERROR.getMessage()));
                    }
                    return Mono.just(CommonService.generateAck());
                });
    }

    private Mono<String> callOnSearch(Map<String, Object> response) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {

        Request onSearchRequest = new Request();
        Message objMessage = (Message) response.get("message");
        Context context = (Context) response.get("context");

        onSearchRequest.setMessage(objMessage);
        context.setProviderId(PROVIDER_ID);
        context.setProviderUri(PROVIDER_URI);

        context.setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);
        onSearchRequest.setContext(context);
        onSearchRequest.getContext().setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);

        String onSearchRequestString = objectMapper.writeValueAsString(onSearchRequest);
        log.info("Processing::Search::CallOnSearch {} .. Message Id is {}", onSearchRequestString, context.getMessageId());

        return euaWebClient.post()
                .uri(GATEWAY_URI + "/" + ConstantsUtils.ON_SEARCH_ENDPOINT)
                .contentType(MediaType.APPLICATION_JSON)
                .header(GlobalConstants.AUTHORIZATION, crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onSearchRequestString, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onSearchRequestString))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    log.error("Unable to call gateway :error::onErrorResume:: {} .. Message Id is {}", error, context.getMessageId());
                    return Mono.error(new HspaException(error.getMessage()));
                });
    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) {

        String catalogResp = ConstantsUtils.RESPONSE_JSON_STRING;

        Catalog catalogObj = null;
        try {
            catalogObj = objectMapper.readValue(catalogResp, Catalog.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        Context context = new Context();

        Date currentDate = new Date(System.currentTimeMillis());
        SimpleDateFormat sdf = new SimpleDateFormat(ConstantsUtils.TIMEFORMAT);
        String timeStamp = sdf.format(currentDate);

        context.setDomain(request.getContext().getDomain());
        context.setCountry(request.getContext().getCountry());
        context.setCity(request.getContext().getCity());
        context.setAction(ConstantsUtils.ON_SEARCH_ENDPOINT);
        context.setConsumerId(request.getContext().getConsumerId());
        context.setConsumerUri(request.getContext().getConsumerUri());
        context.setMessageId(request.getContext().getMessageId());
        context.setTimestamp(timeStamp);
        context.setCoreVersion(request.getContext().getCoreVersion());
        context.setTransactionId(request.getContext().getTransactionId());

        Catalog catalog = new Catalog();
        catalog.setProviders(catalogObj.getProviders());
        catalog.setFulfillments(catalogObj.getFulfillments());
        catalog.setItems(catalogObj.getItems());
        catalog.setDescriptor(catalogObj.getDescriptor());
        catalog.setLocationslist(catalogObj.getLocationslist());

        Message message = new Message();
        message.setCatalog(catalog);

        Map<String, Object> mapResp = new HashMap<>();

        mapResp.put("message", message);
        mapResp.put("context", context);

        return Mono.just(mapResp);

    }

    @Override
    public Mono<String> run(Request request, String s) throws Exception {
        return null;
    }

    @Override
    public Mono<String> logResponse(String result, Request request) {

        log.info("OnSearch::Log::Response:: {} \n Message Id is {}", result, CommonService.getMessageId(request));
        return Mono.just(result);
    }

    @Override
    public boolean updateOrderStatus(String status, String orderId) {
        return false;
    }
}


