package in.gov.abdm.uhi.hspa.service;

import in.gov.abdm.uhi.common.dto.Person;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.hspa.dto.RequestPublicKeyDTO;
import in.gov.abdm.uhi.hspa.dto.RequestSharedKeyDTO;
import in.gov.abdm.uhi.hspa.dto.RequestTokenDTO;
import in.gov.abdm.uhi.hspa.models.*;
import in.gov.abdm.uhi.hspa.repo.*;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.ChatDataDb;
import org.apache.tomcat.util.codec.binary.Base64;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


@Repository
@EnableAsync
public class SaveChatService implements ChatDataDb {
    final
    MessagesRepository messagesRepo;
    final
    ChatUserRepository chatUserRepository;
    final
    ModelMapper modelMapper;
    final
    SharedKeyRepository sharedKeyRepo;
    final
    UserTokenRepository userTokenRepository;
    final
    PublicKeyRepository publicKeyRepository;
    final FileStorageService fileStorageService;
    final WebClient webClient;
    private final PushNotificationService pushNotificationService;
    Logger LOGGER = LoggerFactory.getLogger(SaveChatService.class);
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    @Value("${spring.file.upload-dir}")
    private String uploadDir;
    @Value("${spring.file.download.url}")
    private String downloadPath;
    @Value("${spring.hspa.base.url.public}")
    private String hspaPublicBaseUrl;
    @Value("${spring.media.type.text}")
    private String mediaTypeText;
    @Value("${spring.dateTime.format}")
    private String dateTimeFormat;
    @Value("${spring.media.type.media}")
    private String mediaTypeMedia;
    @Value("${spring.notificationService.baseUrl}")
    private String notificationService_baseUrl;

    public SaveChatService(MessagesRepository messagesRepo, ChatUserRepository chatUserRepository, ModelMapper modelMapper, UserTokenRepository userTokenRepository, PushNotificationService pushNotificationService, PublicKeyRepository publicKeyRepository, SharedKeyRepository sharedKeyRepo, FileStorageService fileStorageService, WebClient webClient) {
        this.messagesRepo = messagesRepo;
        this.chatUserRepository = chatUserRepository;
        this.modelMapper = modelMapper;
        this.sharedKeyRepo = sharedKeyRepo;
        this.userTokenRepository = userTokenRepository;
        this.publicKeyRepository = publicKeyRepository;
        this.pushNotificationService = pushNotificationService;
        this.fileStorageService = fileStorageService;
        this.webClient = webClient;
    }

    public MessagesModel saveChatDataInDb(Request request) throws Exception {
        MessagesModel messagesModelSaved = null;

        String content_type = request.getMessage().getIntent().getChat().getContent().getContent_type();
        if (mediaTypeMedia.equalsIgnoreCase(content_type)) {
            configureFileToBeSaved_Details(request);
        }

        messagesModelSaved = saveMessage(request);
        saveSenderAndReceiver(request);
        LOGGER.info("Message is saved.. sending notification .. Message Id is {}", getMessageId(request));

        return messagesModelSaved;
    }

    private void configureFileToBeSaved_Details(Request request) throws IOException {

        String content_fileName = request.getContext().getMessageId() + request.getMessage().getIntent().getChat().getContent().getContent_fileName();
        LOGGER.info("Media file type received.. File name is  ->> {} .. Message Id is {}", content_fileName, getMessageId(request));
        Files.createDirectories(Paths.get(uploadDir).toAbsolutePath().normalize());

        writeFileToDisk(request, content_fileName);

        String content_url = hspaPublicBaseUrl + downloadPath + content_fileName;
        LOGGER.info("Setting content URL to ->> ->> {}", content_url);
        request.getMessage().getIntent().getChat().getContent().setContent_url(content_url);
    }

    private void writeFileToDisk(Request request, String content_fileName) throws IOException {
        try (OutputStream stream = new FileOutputStream(uploadDir + "/" + content_fileName)) {
            String content_value = request.getMessage().getIntent().getChat().getContent().getContent_value();
            byte[] fileBytes = Base64.decodeBase64(content_value);
            stream.write(fileBytes);
            LOGGER.info("File is saved.. File name is  ->> {} .. Message Id is {}", content_fileName, getMessageId(request));

        }
    }

    private String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
    }

    void saveSenderAndReceiver(Request request) throws Exception {
        ChatUserModel sender = getSenderOrReceiver(request.getMessage().getIntent().getChat().getSender().getPerson());

        ChatUserModel receiver = getSenderOrReceiver(request.getMessage().getIntent().getChat().getReceiver().getPerson());

        List<ChatUserModel> user = new ArrayList<>();
        user.add(receiver);
        user.add(sender);

        List<ChatUserModel> saveAll = chatUserRepository.saveAll(user);
        if (saveAll.isEmpty())
            throw new Exception("Error occurred while saving data");
    }

    private ChatUserModel getSenderOrReceiver(Person request) {
        ChatUserModel sender = new ChatUserModel();
        sender.setUserId(request.getId());
        sender.setUserName(request.getName());
        sender.setImage(request.getImage());
        return sender;
    }

    MessagesModel saveMessage(Request request) {

        MessagesModel m = new MessagesModel();
        m.setContentId(request.getMessage().getIntent().getChat().getContent().getContent_id());
        m.setReceiver(request.getMessage().getIntent().getChat().getReceiver().getPerson().getId());
        m.setSender(request.getMessage().getIntent().getChat().getSender().getPerson().getId());
        m.setTime(getLocalDateTimeFromString(request));
        String content_type = request.getMessage().getIntent().getChat().getContent().getContent_type();
        if ("text".equalsIgnoreCase(content_type)) {
            m.setContentValue(request.getMessage().getIntent().getChat().getContent().getContent_value());
        }
        m.setContentUrl(request.getMessage().getIntent().getChat().getContent().getContent_url());
        m.setContentType(content_type);
        m.setConsumerUrl(request.getContext().getConsumerUri());
        m.setProviderUrl(request.getContext().getProviderUri());
        return messagesRepo.save(m);
    }

    public List<ChatUserModel> getUserDetails(String userId) {
        return chatUserRepository.findByUserId(userId);
    }

    @Override
    public List<MessagesModel> getMessageDetails() {
        return messagesRepo.findAll();
    }

    @Override
    public List<MessagesModel> getMessagesBetweenTwo(String sender, String receiver, Integer pageNumber, Integer pageSize) {
        Pageable p = PageRequest.of(pageNumber, pageSize, Sort.by("time").ascending());
        Page<MessagesModel> findBySenderAndReceiver = messagesRepo.findBySenderAndReceiver(sender, receiver, p);
        Page<MessagesModel> findBySenderAndReceiver2 = messagesRepo.findBySenderAndReceiver(receiver, sender, p);
        List<MessagesModel> combination = new ArrayList<>();
        combination.addAll(findBySenderAndReceiver.getContent());
        combination.addAll(findBySenderAndReceiver2.getContent());
        return combination;
    }

    public UserTokenModel saveUserToken(RequestTokenDTO requesttoken) {

        UserTokenModel ut = new UserTokenModel();
        String userid = requesttoken.getUserName() + "|" + requesttoken.getDeviceId();
        ut.setUserId(userid);
        ut.setUserName(requesttoken.getUserName());
        ut.setToken(requesttoken.getToken());
        ut.setDeviceId(requesttoken.getDeviceId());
        return userTokenRepository.save(ut);
    }

    @Transactional
    public void deleteToken(RequestTokenDTO tokenDTO) {
        Integer userTokenModel = userTokenRepository.deleteByUserId(tokenDTO.getUserName() + "|" + tokenDTO.getDeviceId());
        if (userTokenModel <= 0) {
            throw new RuntimeException("Error logging out. Either Token not found or some error occurred");
        }
    }


    public void callNotificationService(Request request) {
        webClient.post().uri(notificationService_baseUrl + "/sendNotification")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).map(Exception::new))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).map(Exception::new))
                .toEntity(String.class)
                .doOnError(throwable -> LOGGER.error("Error sending notification--- {}", throwable.getMessage())).subscribe(res -> LOGGER.info("Sent notification--- {}", res.getBody()));
    }


    private LocalDateTime getLocalDateTimeFromString(Request request) {
        DateTimeFormatter ofPattern = DateTimeFormatter.ofPattern(dateTimeFormat, Locale.ENGLISH);
        String time = request.getMessage().getIntent().getChat().getTime().getTimestamp();
        return LocalDateTime.parse(time, ofPattern);
    }


    public PublicKeyModel savePublicKey(RequestPublicKeyDTO request) {
        PublicKeyModel pkm = new PublicKeyModel();
        pkm.setUserName(request.getUserName());
        pkm.setPublicKey(request.getPublicKey());
        return publicKeyRepository.save(pkm);


    }

    public List<PublicKeyModel> getKeyDetails(String userName) {
        return publicKeyRepository.findByUserName(userName);
    }


    public SharedKeyModel saveSharedKey(RequestSharedKeyDTO request) {

        if (request.getPublicKey() != null) {
            SharedKeyModel sk = new SharedKeyModel();
            sk.setUserName(request.getUserName());
            sk.setPublicKey(request.getPublicKey());
            sk.setPrivateKey(request.getPrivateKey());
            List<SharedKeyModel> skl = getSharedKeyDetails(request.getUserName());
            if (skl.isEmpty()) {
                return sharedKeyRepo.save(sk);
            }
            return skl.get(0);
        } else
            return null;
    }


    public List<SharedKeyModel> getSharedKeyDetails(String userName) {
        return sharedKeyRepo.findByUserName(userName);
    }


}