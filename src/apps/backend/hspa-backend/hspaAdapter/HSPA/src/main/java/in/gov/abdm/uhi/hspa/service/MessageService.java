package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.hspa.models.MessagesModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

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
    private final SimpMessagingTemplate messagingTemplate;
    @Autowired
    WebClient euaWebClient;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.media.type.media}")
    private String mediaTypeMedia;
    @Value("${spring.file.upload-dir}")
    private String uploadDir;

    public MessageService(SimpMessagingTemplate messagingTemplate, ObjectMapper mapper, SaveChatService chatService, WebClient webClient, FileStorageService fileStorageService) {
        this.messagingTemplate = messagingTemplate;
        this.mapper = mapper;
        this.chatService = chatService;
        this.webClient = webClient;
        this.fileStorageService = fileStorageService;
    }

    private static Response generateAck() {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("ACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new in.gov.abdm.uhi.common.dto.Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    public Mono<Response> processor(String request) {

        Request objRequest = null;
        Response ack = generateAck();


        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            LOGGER.info("Processing::Message::Request:: {}.. Message Id is {}", request, getMessageId(objRequest));
            Request finalObjRequest = objRequest;
            run(objRequest, request)
                    .filter(res -> finalObjRequest.getContext().getAction().equals(ConstantsUtils.MESSAGE_ACTION))
                    .flatMap(res -> callMessageApiOnEua(finalObjRequest))
                    .subscribe();
        } catch (Exception ex) {
            ack = CommonService.setMessageidAndTxnIdInNack(objRequest, ex);
        }

        return Mono.just(ack);
    }

    private void pushMessageToWebSocket(Request finalObjRequest) throws JsonProcessingException {
        String request = mapper.writeValueAsString(finalObjRequest);
        String receiver = finalObjRequest.getMessage().getIntent().getChat().getReceiver().getPerson().getCred();
        String sender = finalObjRequest.getMessage().getIntent().getChat().getSender().getPerson().getCred();
        //String concatReceiverSender = concatReceiverSender(receiver,sender);
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

    private Mono<String> callMessageApiOnEua(Request chatRequest) {

        chatRequest.getContext().setAction(ConstantsUtils.ON_MESSAGE_ACTION);
        chatRequest.getContext().setProviderUri(PROVIDER_URI);

        LOGGER.info("Processing:: {} ::callMessageOnEua {} .. Message Id is {}", ConstantsUtils.ON_MESSAGE_ACTION, chatRequest, getMessageId(chatRequest));

        return euaWebClient.post()
                .uri(chatRequest.getContext().getConsumerUri() + "/" + ConstantsUtils.ON_MESSAGE_ACTION)
                .body(BodyInserters.fromValue(chatRequest))
                .retrieve()
                .bodyToMono(String.class)
                .doOnNext(x -> {
                    try {
                        LOGGER.info("Response from Webclient call for Chat {} .. Message Id is {}", new ObjectMapper().writeValueAsString(x), getMessageId(chatRequest));
                    } catch (JsonProcessingException e) {
                        e.printStackTrace();
                    }
                })
                .onErrorResume(error -> {
                    LOGGER.error("Unable to call eua :error::onErrorResume:: {} Message Id is {}", error, getMessageId(chatRequest));
                    return Mono.empty();
                });
    }

    private String concatReceiverSender(String receiver, String sender) {
        return sender + "|" + receiver;
    }
}
