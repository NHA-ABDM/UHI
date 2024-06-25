package in.gov.abdm.uhi.discovery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.discovery.configuration.AppConfig;
import in.gov.abdm.uhi.discovery.dto.ListofSubscribers;
import in.gov.abdm.uhi.discovery.exception.GatewayError;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.exception.InvalidKeyError;
import in.gov.abdm.uhi.discovery.security.Crypt;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.InvalidKeySpecException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashSet;
import java.util.List;

@Service
public class HSPAService {

    private static final Logger LOGGER = LoggerFactory.getLogger(HSPAService.class);
    final
    AppConfig appConfig;
    final
    GatewayUtility gatewayUtil;
    final
    WebClient getWebClient;
    final
    Crypt crypt;
    @Value("${spring.application.isHeaderEnabled}")
    Boolean isHeaderEnabled;
    @Value("${spring.application.gateway_subsId}")
    private String gatewaySubsId;
    @Value("${spring.application.gateway_pubKeyId}")
    private String gatewayPubKeyId;
    @Value("${spring.application.gateway_privKey}")
    private String gatewayPrivateKey;

    final
    ObjectMapper objectMapper;

    public HSPAService(AppConfig appConfig, GatewayUtility gatewayUtil, WebClient getWebClient, Crypt crypt, ObjectMapper objectMapper) {
        this.appConfig = appConfig;
        this.gatewayUtil = gatewayUtil;
        this.getWebClient = getWebClient;
        this.crypt = crypt;
        this.objectMapper = objectMapper;
    }

    Mono<String> checklookupforHSPAs(String res, Request req, String requestId) throws JsonProcessingException {
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        if (res.contains("Failed")) {
            Mono<String> resp = gatewayUtil.generateNack(GlobalConstants.LOOKUP_FAILED,
                    GatewayError.LOOKUP_FAILED.getCode(), req);
            LOGGER.error("Failed: {} | Request ID: {} | Message ID: {} | Log: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, req.getContext().getMessageId(), resp.log());
            return resp;
        } else {
            LOGGER.error("73 HSPAService checklookupforHSPAs() Success: {} | Request ID: {} | Message ID: {} | HSPA Lookup success : {} getLocation {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, req.getContext().getMessageId(), res,req.getMessage().getIntent().getLocation());
            Mono<String> data = Mono.just(res);
            return data.flatMapIterable(p -> extractURIListNew(p, req))
            .flatMap(uris ->
                {
                    try {
                        LOGGER.error("79 HSPAService checklookupforHSPAs() {} | Request ID: {} | Message ID: {} | Sending signal to HSPA : {} getLocation {} ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, req.getContext().getMessageId(), uris,req.getMessage().getIntent().getLocation());
                        return sendSignalToHSPANew(uris, req);
                    } catch (NoSuchAlgorithmException | InvalidKeySpecException | NoSuchProviderException |
                             JsonProcessingException e) {
                        LOGGER.error("Error: {} | Request ID: {} | Message ID: {} | Exception: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, req.getContext().getMessageId(), e.getMessage());
                        gatewayUtil.logErrorMessageForKibana(req,e.getMessage(), GatewayError.INVALID_KEY.getCode());
                        return Mono.error(new InvalidKeyError(GatewayError.INVALID_KEY.getMessage()));
                    }
                }
            ).then(Mono.just(gatewayUtil.generateAck())).log();
        }
    }

    private List<String> extractURIListNew(String request, Request req) {

        List<String> listValue = new ArrayList<>();
        try {
            ListofSubscribers listOfSubscribers = null;
            listOfSubscribers = appConfig.objectMapper().readValue(request, ListofSubscribers.class);

            listOfSubscribers.getMessage().forEach(data -> {

                if (GlobalConstants.HSPA.equalsIgnoreCase(data.getType())) {
                    listValue.add(data.getSubscriber_url() + "|" + data.getSubscriber_id());
                    LOGGER.info("103 extractURIListNew :: {} | {}", req.getContext().getMessageId(), data);
                }
            });
            if("Online".equalsIgnoreCase(req.getMessage().getIntent().getFulfillment().getType())){
                List<String> res = new ArrayList<>(new HashSet<>(listValue));
                LOGGER.info("108 extractURIListNew :: {} count {} ",res,res.size());
                return res;
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage());
        }
        return listValue;
    }

    private Mono<String> sendSignalToHSPANew(String uriSubsid, Request req) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {
        String[] uriSubsidArr = uriSubsid.split("\\|");
        String uri = uriSubsidArr[0].strip();
        String subsId = uriSubsidArr[1];

        req.getContext().setProviderId(subsId);
        req.getContext().setProviderId(subsId);

        String stringRequest = objectMapper.writeValueAsString(req);

        LOGGER.info("114 HSPAService sendSignalToHSPANew() getTransactionId {} | RequesterService::info::sending Request to stringRequest::{}, req::{}", req.getContext().getTransactionId(), stringRequest, req.getMessage().getIntent().getLocation());
        String headers = getHspaHeaders(stringRequest);
        String headersString = String.valueOf(headers);
        

        LOGGER.info("124 HSPAService sendSignalToHSPANew() {} | RequesterService::info::sending Request to HSPA::{}, URL::{} | transactionid {} ", req.getContext().getMessageId(), subsId, uri, req.getContext().getTransactionId());

        Mono<String> response = null;
        response = getWebClient.post().uri(uri + "/search")
                .header(GlobalConstants.X_GATEWAY_AUTHORIZATION, Boolean.TRUE.equals(isHeaderEnabled) ? headersString : "")                    //.header("X-Gateway-Authorization", headersString)
                .contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(stringRequest)).retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        resp -> resp.bodyToMono(String.class)
                                .flatMap(error -> Mono.error(new GatewayException(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        resp -> resp
                                .bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
                .bodyToMono(String.class)
                .doOnNext(p -> LOGGER.info(
                        "139 HSPAService sendSignalToHSPANew() created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}",
                        new Timestamp(System.currentTimeMillis()), req.getContext().getTransactionId(),
                        req.getContext().getMessageId(), req.getContext().getConsumerId(), subsId,
                        req.getContext().getDomain(), req.getContext().getCity(), req.getContext().getAction()))
                .onErrorResume(error -> {
                    gatewayUtil.logErrorMessageForKibana(req,error.getMessage(), GatewayError.INTERNAL_SERVER_ERROR.getCode());
                    return gatewayUtil.generateNack("HSPA exception",
                            GatewayError.HSPA_FAILED.getCode(), req);

                }).log();
        return response;
    }

    public String getHspaHeaders(String reqString) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, JsonProcessingException {
        return crypt.generateAuthorizationParams(gatewaySubsId, gatewayPubKeyId, reqString, Crypt.getPrivateKey("Ed25519", Base64.getDecoder().decode(gatewayPrivateKey)));
    }
}
