package in.gov.abdm.uhi.hspa.service;

import in.gov.abdm.uhi.common.dto.Person;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.hspa.dto.PushNotificationRequestDTO;
import in.gov.abdm.uhi.hspa.dto.RequestTokenDTO;
import in.gov.abdm.uhi.hspa.models.ChatUserModel;
import in.gov.abdm.uhi.hspa.models.MessagesModel;
import in.gov.abdm.uhi.hspa.models.UserTokenModel;
import in.gov.abdm.uhi.hspa.repo.ChatUserRepository;
import in.gov.abdm.uhi.hspa.repo.MessagesRepository;
import in.gov.abdm.uhi.hspa.repo.UserTokenRepository;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.ChatDataDb;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutionException;


@Repository
public class SaveChatService implements ChatDataDb {
	Logger LOGGER = LoggerFactory.getLogger(SaveChatService.class);

	
	final
	MessagesRepository messagesRepo;

	final
	ChatUserRepository chatUserRepository;

	final
	ModelMapper modelMapper;

	final
	UserTokenRepository userTokenRepository;

	private final PushNotificationService pushNotificationService;

	@Value("${spring.provider_uri}")
	String PROVIDER_URI;

	public SaveChatService(MessagesRepository messagesRepo, ChatUserRepository chatUserRepository, ModelMapper modelMapper, UserTokenRepository userTokenRepository, PushNotificationService pushNotificationService) {
		this.messagesRepo = messagesRepo;
		this.chatUserRepository = chatUserRepository;
		this.modelMapper = modelMapper;
		this.userTokenRepository = userTokenRepository;
		this.pushNotificationService = pushNotificationService;
	}


	public MessagesModel saveChatDataInDb(Request request) throws Exception {
		MessagesModel messagesModelSaved = null;

			messagesModelSaved = saveMessage(request);
			saveSenderAndReceiver(request);
			sendNotificationToReceiver(request);


		return messagesModelSaved;
	}

	private void saveSenderAndReceiver(Request request) throws Exception {
		ChatUserModel sender = getSenderOrReceiver(request.getMessage().getIntent().getChat().getSender().getPerson());

		ChatUserModel receiver = getSenderOrReceiver(request.getMessage().getIntent().getChat().getReceiver().getPerson());

		List<ChatUserModel> user=new ArrayList<>();
		user.add(receiver);
		user.add(sender);

		List<ChatUserModel> saveAll = chatUserRepository.saveAll(user);
		if(saveAll.isEmpty())
			throw new Exception("Error occurred while saving data");
	}

	private ChatUserModel getSenderOrReceiver(Person request) {
		ChatUserModel sender=new ChatUserModel();
		sender.setUserId(request.getCred());
		sender.setUserName(request.getName());
		sender.setImage(request.getImage());
		return sender;
	}

	private MessagesModel saveMessage(Request request) {
		MessagesModel m = new MessagesModel();
		m.setContentId(request.getMessage().getIntent().getChat().getContent().getContent_id());
		m.setContentValue(request.getMessage().getIntent().getChat().getContent().getContent_value());
		m.setReceiver(request.getMessage().getIntent().getChat().getReceiver().getPerson().getCred());
		m.setSender(request.getMessage().getIntent().getChat().getSender().getPerson().getCred());
		m.setTime(getLocalDateTimeFromString(request));
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
		Pageable p= PageRequest.of(pageNumber, pageSize, Sort.by("time").ascending());
		Page<MessagesModel> findBySenderAndReceiver = messagesRepo.findBySenderAndReceiver(sender,receiver, p);
		Page<MessagesModel> findBySenderAndReceiver2 = messagesRepo.findBySenderAndReceiver(receiver, sender, p);
		List<MessagesModel> combination=new ArrayList<>();
		combination.addAll(findBySenderAndReceiver.getContent());
		combination.addAll(findBySenderAndReceiver2.getContent());
		return combination;
	}

	public UserTokenModel saveUserToken(RequestTokenDTO requesttoken) {

		UserTokenModel ut=new UserTokenModel();
		String userid=requesttoken.getUserName()+"|"+requesttoken.getDeviceId();
		ut.setUserId(userid);
		ut.setUserName(requesttoken.getUserName());
		ut.setToken(requesttoken.getToken());
		ut.setDeviceId(requesttoken.getDeviceId());
		return userTokenRepository.save(ut);
	}

	public List<UserTokenModel> getUserTokenByName(String userName) {
		return userTokenRepository.findByUserName(userName);
	}

	public void sendNotificationToReceiver(Request request) throws ExecutionException, InterruptedException {
		String receiver = request.getMessage().getIntent().getChat().getReceiver().getPerson().getCred();
		List<UserTokenModel> userTokenModelByName = getUserTokenByName(receiver);
		sendExtractedDataAsNotification(request, receiver, userTokenModelByName);
	}

	private void sendExtractedDataAsNotification(Request request, String receiver, List<UserTokenModel> userTokenModelByName) throws ExecutionException, InterruptedException {
		for (UserTokenModel token : userTokenModelByName) {
			PushNotificationRequestDTO pushNotification = new PushNotificationRequestDTO();
			pushNotification.setTitle(request.getMessage().getIntent().getChat().getSender().getPerson().getName());
			pushNotification.setMessage(request.getMessage().getIntent().getChat().getContent().getContent_value());
			pushNotification.setSenderAbhaAddress(request.getMessage().getIntent().getChat().getSender().getPerson().getCred());
			pushNotification.setReceiverAbhaAddress(receiver);
			pushNotification.setProviderUri(request.getContext().getProviderUri());
			pushNotification.setType(ConstantsUtils.CHAT);
			pushNotification.setGender(request.getMessage().getIntent().getChat().getSender().getPerson().getGender());
			pushNotification.setToken(token.getToken());
			pushNotificationService.sendPushNotificationToToken(pushNotification);

			pushNotification = null;
		}
	}

	private LocalDateTime getLocalDateTimeFromString(Request request) {
		DateTimeFormatter ofPattern = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss", Locale.ENGLISH);
		String time= request.getMessage().getIntent().getChat().getTime().getTimestamp();
			return LocalDateTime.parse(time, ofPattern);
	}


}