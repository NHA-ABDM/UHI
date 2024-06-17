package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.hspa.exceptions.GatewayError;
import in.gov.abdm.uhi.hspa.exceptions.HspaException;
import in.gov.abdm.uhi.hspa.exceptions.HeaderVerificationFailedError;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.MessagesModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import in.gov.abdm.uhi.hspa.utils.Crypt;
import in.gov.abdm.uhi.hspa.utils.HspaUtility;
import in.gov.abdm.uhi.hspa.utils.GlobalConstants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Service
public class MessageService implements IService {

    private static final Logger LOGGER = LogManager.getLogger(MessageService.class);
    final
    ObjectMapper mapper;

    final
    SaveChatService chatService;

    final
    WebClient webClient;
    final FileStorageService fileStorageService;
    final ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;
    final
    WebClient euaWebClient;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.media.type.media}")
    private String mediaTypeMedia;
    @Value("${spring.file.upload-dir}")
    private String uploadDir;

    @Value("${spring.header.isHeaderEnabled}")
    private String isHeaderEnabled;

    final
    HspaUtility hspaUtility;

    @Value("${spring.provider_id}")
    String PROVIDER_ID;

    @Value("${spring.gateway.publicKey}")
    String GATEWAY_PUBLIC_KEY;

    @Value("${spring.hspa.subsId}")
    String HSPA_SUBS_ID;

    @Value("${spring.hspa.privKey}")
    String HSPA_PRIV_KEY;

    @Value("${spring.hspa.pubKeyId}")
    String HSPA_PUBKEY_ID;

    @Autowired
    Crypt crypt;

    public MessageService(SimpMessagingTemplate messagingTemplate, ObjectMapper mapper, SaveChatService chatService, WebClient webClient, FileStorageService fileStorageService, ObjectMapper objectMapper, WebClient euaWebClient, HspaUtility hspaUtility) {
        this.messagingTemplate = messagingTemplate;
        this.mapper = mapper;
        this.chatService = chatService;
        this.webClient = webClient;
        this.fileStorageService = fileStorageService;
        this.objectMapper = objectMapper;
        this.euaWebClient = euaWebClient;
        this.hspaUtility = hspaUtility;
    }

    public Mono<Response> processor(String request, Map<String, String> headers) throws Exception {
        Request objRequest = objectMapper.readValue(request, Request.class);

        if(Boolean.parseBoolean(isHeaderEnabled) && ConstantsUtils.ON_MESSAGE_ACTION.equalsIgnoreCase(objRequest.getContext().getAction())) {
            return processMessageCallWithHeaderVerification(request, headers, objRequest);
        }
        else {
            return processMessageCall(request, objRequest);
        }
    }

    private Mono<Response> processMessageCallWithHeaderVerification(String request, Map<String, String> headers, Request objRequest) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        HspaUtility.checkAuthHeader(headers, objRequest);
        Map<String, String> keyIdMap = hspaUtility.getKeyIdMapFromHeaders(headers, objRequest);
        Mono<List<Subscriber>> subscriberDetails = hspaUtility.getSubscriberDetailsOfEua(objRequest, keyIdMap.get("subscriber_id"),keyIdMap.get("pub_key_id"));
        return subscriberDetails.flatMap(lookupRes -> {
            if (!lookupRes.isEmpty()) {
                try {
                    if (hspaUtility.verifyHeaders(objRequest, headers, GlobalConstants.AUTHORIZATION.toLowerCase(), lookupRes.get(0).getEncr_public_key(), request)) {
                        LOGGER.info("Processing::Message::Request:: {}.. Message Id is {}", request, getMessageId(objRequest));
                        processMessageCall(request, objRequest);
                    } else {
                        LOGGER.error("{} | MessageService::processor::Header verification failed", objRequest.getContext().getMessageId());
                        return Mono.error(new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage()));
                    }
                } catch (Exception e) {
                    LOGGER.error("{} | InitService::processor::error:: {}", objRequest.getContext().getMessageId(), e.getMessage());
                    Error err = new Error(String.valueOf(GatewayError.INTERNAL_SERVER_ERROR.getCode()), GatewayError.INTERNAL_SERVER_ERROR.getMessage());
                    return Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
                }
            }
            return Mono.just(CommonService.generateAck());
        });
    }

    private Mono<Response> processMessageCall(String request, Request finalObjRequest1) throws Exception {
        run(finalObjRequest1, request)
                .filter(res -> finalObjRequest1.getContext().getAction().equals(ConstantsUtils.MESSAGE_ACTION))
                .flatMap(res -> {
                    try {
                        return callMessageApiOnEua(finalObjRequest1);
                    } catch (JsonProcessingException | NoSuchAlgorithmException e) {
            return Mono.error(new HspaException(e.getMessage()));
        } catch (NoSuchProviderException | InvalidKeySpecException e) {
            return Mono.error(new InvalidKeyException(e.getMessage()));
        }
                })
                .subscribe();
        return Mono.just(CommonService.generateAck());
    }

    private void pushMessageToWebSocket(Request finalObjRequest) throws JsonProcessingException {
        String request = mapper.writeValueAsString(finalObjRequest);
        String receiver = finalObjRequest.getMessage().getIntent().getChat().getReceiver().getPerson().getCred();
        String sender = finalObjRequest.getMessage().getIntent().getChat().getSender().getPerson().getCred();
        LOGGER.info("Webclient Call {}", finalObjRequest);
        LOGGER.info("Sender is {}, Receiver is {}", sender, receiver);
        final String concatReceiverSender = finalObjRequest.getContext().getTransactionId();
        messagingTemplate.convertAndSendToUser(concatReceiverSender, ConstantsUtils.QUEUE_SPECIFIC_USER, request);
    }

    private String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
    }

    @Override
    public Mono<String> run(Request objReq, String request) throws Exception {
        String contentType = objReq.getMessage().getIntent().getChat().getContent().getContent_type();
        MessagesModel messageSaved = new MessagesModel();
        boolean checkIfContentTypeTextOrMedia = contentType.equalsIgnoreCase("text") || contentType.equalsIgnoreCase("media");
        if (checkIfContentTypeTextOrMedia) {
            messageSaved = chatService.saveChatDataInDb(objReq);
            chatService.callNotificationService(objReq);
            LOGGER.info("DB call done... Message Id is {}", getMessageId(objReq));
        } else {
            LOGGER.info("Message not saved to database. Content type is {}, Message Id is {}", contentType, getMessageId(objReq));
        }
        String action = objReq.getContext().getAction();
        actionsInCaseOf_OnMessageAction(objReq, messageSaved, action);
        return logResponse(request, objReq);
    }

    @Override
    public Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception {
        return null;
    }

    private void actionsInCaseOf_OnMessageAction(Request objReq, MessagesModel messageSaved, String action) throws JsonProcessingException {
        if (ConstantsUtils.ON_MESSAGE_ACTION.equals(action)) {
            String contentUrl = messageSaved.getContentUrl();
            objReq.getMessage().getIntent().getChat().getContent().setContent_url(contentUrl);
            String content_type = objReq.getMessage().getIntent().getChat().getContent().getContent_type();
            sendNullContentValueInCaseOfFileSharing(objReq, content_type);
            LOGGER.info("Saved Content url for omMessage recieved ->> {} , Message Id is {}", contentUrl, getMessageId(objReq));
            pushMessageToWebSocket(objReq);
        }
    }

    private void sendNullContentValueInCaseOfFileSharing(Request objReq, String content_type) {
        if (mediaTypeMedia.equalsIgnoreCase(content_type))
            objReq.getMessage().getIntent().getChat().getContent().setContent_value(null);
    }

    @Override
    public Mono<String> logResponse(String result, Request request) {
        return Mono.just(result);
    }

    @Override
    public boolean updateOrderStatus(String status, String orderId) throws UserException {
        return false;
    }

    private Mono<String> callMessageApiOnEua(Request chatRequest) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {

        chatRequest.getContext().setAction(ConstantsUtils.ON_MESSAGE_ACTION);
        chatRequest.getContext().setProviderUri(PROVIDER_URI);
        chatRequest.getContext().setProviderId(ConstantsUtils.PROVIDERID);

        String onMessageResponse = mapper.writeValueAsString(chatRequest);

        LOGGER.info("Processing:: {} ::callMessageOnEua {} .. Message Id is {}", ConstantsUtils.ON_MESSAGE_ACTION, onMessageResponse, getMessageId(chatRequest));

        return euaWebClient.post()
                .uri(chatRequest.getContext().getConsumerUri() + "/" + ConstantsUtils.ON_MESSAGE_ACTION)
                .header(GlobalConstants.AUTHORIZATION,crypt.generateAuthorizationParams(HSPA_SUBS_ID, HSPA_PUBKEY_ID, onMessageResponse, Crypt.getPrivateKey(Crypt.SIGNATURE_ALGO, Base64.getDecoder().decode(HSPA_PRIV_KEY))))
                .body(BodyInserters.fromValue(onMessageResponse))
                .retrieve()
                .bodyToMono(String.class)
                .doOnNext(x -> {
                    try {
                        LOGGER.info("Response from Webclient call for Chat {} .. Message Id is {}", new ObjectMapper().writeValueAsString(x), getMessageId(chatRequest));
                    } catch (JsonProcessingException e) {
                        LOGGER.error("{} | CallMessageApiOnEua() Invalid Json error",e.getMessage());
                         Mono.error(new HspaException(e.getMessage()));
                    }
                })
                .onErrorResume(error -> {
                    LOGGER.error("Unable to call eua :error::onErrorResume:: {} Message Id is {}", error, getMessageId(chatRequest));
                    return Mono.error(new HspaException(error.getLocalizedMessage()));
                });
    }
}
