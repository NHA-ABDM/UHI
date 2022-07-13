package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class MessageService implements IService {
    final
    ObjectMapper mapper;

    final
    SaveChatService chatService;

    final
    WebClient webClient;

    private final SimpMessagingTemplate messagingTemplate;

    @Value("${spring.provider_uri}")
    String PROVIDER_URI;

    private static final Logger LOGGER = LogManager.getLogger(MessageService.class);

    public MessageService(SimpMessagingTemplate messagingTemplate, ObjectMapper mapper, SaveChatService chatService, WebClient webClient) {
        this.messagingTemplate = messagingTemplate;
        this.mapper = mapper;
        this.chatService = chatService;
        this.webClient = webClient;
    }

    @Override
    public Mono<Response> processor(String request) throws Exception {

        Request objRequest;
        Response ack = generateAck(mapper);

        LOGGER.info("Processing::Message::Request::" + request);
        System.out.println("Processing::Message::Request::" + request);

            objRequest = new ObjectMapper().readValue(request, Request.class);
            Request finalObjRequest = objRequest;
            String action = finalObjRequest.getContext().getAction();
            if(ConstantsUtils.ON_MESSAGE_ACTION.equals(action))
                pushMessageToWebSocket(request, finalObjRequest);

            run(finalObjRequest)
                    .filter(res -> finalObjRequest.getContext().getAction().equals(ConstantsUtils.MESSAGE_ACTION))
                    .flatMap(res -> callMessageApiOnEua(finalObjRequest))
                    .subscribe();



        return Mono.just(ack);
    }

    private void pushMessageToWebSocket(String request, Request finalObjRequest) {
        String receiver= finalObjRequest.getMessage().getIntent().getChat().getReceiver().getPerson().getCred();
        String sender= finalObjRequest.getMessage().getIntent().getChat().getSender().getPerson().getCred();


        String concatReceiverSender = concatReceiverSender(receiver,sender);
        messagingTemplate.convertAndSendToUser(concatReceiverSender, ConstantsUtils.QUEUE_SPECIFIC_USER, request);
    }

    @Override
    public Mono<String> run(Request request) throws Exception {
            return logResponse(chatService.saveChatDataInDb(request).toString());
    }

    @Override
    public Mono<String> logResponse(String result) {
        LOGGER.info(result);
        return Mono.just(result);
    }

    private Mono<String> callMessageApiOnEua(Request chatRequest) {

       chatRequest.getContext().setAction(ConstantsUtils.ON_MESSAGE_ACTION);
       chatRequest.getContext().setProviderUri(PROVIDER_URI);

        LOGGER.info("Processing::"+ ConstantsUtils.ON_MESSAGE_ACTION +"::callMessageOnEua" + chatRequest);
        System.out.println("Processing::"+ ConstantsUtils.ON_MESSAGE_ACTION +"::callMessageOnEua" + chatRequest);


        return webClient.post()
                .uri(chatRequest.getContext().getConsumerUri() +"/"+ ConstantsUtils.ON_MESSAGE_ACTION)
                .body(BodyInserters.fromValue(chatRequest))
                .retrieve()
                .bodyToMono(String.class)
                .doOnNext(x -> {
                    try {
                        LOGGER.info("Response from Webclient call for Chat "+new ObjectMapper().writeValueAsString(x));
                    } catch (JsonProcessingException e) {
                        e.printStackTrace();
                    }
                })
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Unable to call eua :error::onErrorResume::" + error);
                    return Mono.empty();
                });
    }


    private static Response generateAck(ObjectMapper mapper) {

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

    private static Response generateNack(ObjectMapper mapper, Exception js) {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new Error();
        err.setMessage(js.getMessage());
        err.setType("MessageService");
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    private String concatReceiverSender(String receiver, String sender) {
        return sender+"|"+receiver ;
    }
}
