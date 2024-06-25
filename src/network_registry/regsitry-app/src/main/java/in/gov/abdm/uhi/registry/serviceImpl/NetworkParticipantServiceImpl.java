package in.gov.abdm.uhi.registry.serviceImpl;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.*;

import in.gov.abdm.uhi.common.dto.HeaderDTO;
import in.gov.abdm.uhi.registry.dto.*;
import in.gov.abdm.uhi.registry.exception.*;
import in.gov.abdm.uhi.registry.repository.*;
import in.gov.abdm.uhi.registry.service.NetworkParticipantService;
import in.gov.abdm.uhi.registry.util.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;

@Service
public class NetworkParticipantServiceImpl implements NetworkParticipantService {
	private static final Logger logger = LogManager.getLogger(NetworkParticipantServiceImpl.class);
	@Autowired
	Crypt cr;
	private static Random rnd;
	@Autowired
	NetworkParticipantRepository networkParticipantRepository;


	@PersistenceContext
	private EntityManager entityManager;

	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;

	@Value("${uhi.city.filter}")
	Boolean cityFilter;

	@Autowired
	GatewayUtility gatewayUtil;


	@Autowired
			ObjectMapper objectMapper;


	@Autowired
	ModelMapper mapper;
	@Autowired
	Crypt crypt;

	@Value("${spring.application.gateway_pubKey}")
	private String gatewayPublicKey;
	@Autowired
	private ParticipantKeyRepository participantKeyRepository;

	@Override
	public NetworkParticipant saveNetworkParticipant(NetworkParticipant networkParticipant) {
		logger.debug("NetworkParticipantServiceImpl::saveNetworkParticipant()");
		logger.info("NetworkParticipantServiceImpl::saveNetworkParticipant()");
		NetworkParticipant participant = new NetworkParticipant();
		participant.setParticipantId(networkParticipant.getParticipantId());
		NetworkParticipant participantData = networkParticipantRepository
				.findByParticipantId(networkParticipant.getParticipantId());
		
		if (participantData == null) {
			participant.setParticipantId(networkParticipant.getParticipantId());
			participant.setParticipantName(networkParticipant.getParticipantName());
		} else {
			throw new RecordAlreadyExists("Participant id already exist");
		}
		return networkParticipantRepository.save(participant);
	}

	@Override
	public NetworkParticipant updateNetworkParticipant(NetworkParticipant networkParticipant) {
		logger.debug("NetworkParticipantServiceImpl::updateNetworkParticipant()");
		logger.info("NetworkParticipantServiceImpl::updateNetworkParticipant()");
		this.getOneNetworkParticipant(networkParticipant.getId());
		try {
		return networkParticipantRepository.save(networkParticipant);
		}catch (DataIntegrityViolationException e) {
			throw new RecordAlreadyExists("Participant id already exist");
			
		}
	}

	@Override
	public List<NetworkParticipant> findAllNetworkParticipant() {
		logger.debug("NetworkParticipantServiceImpl::findAllNetworkParticipant()");
		List<NetworkParticipant> allNetworkParticipantData = networkParticipantRepository.findAll();
		logger.debug("NetworkParticipantServiceImpl::findAllNetworkParticipant() allNetworkParticipantData :: {} ",allNetworkParticipantData.size());
		if (allNetworkParticipantData.isEmpty()) {
			logger.error("NetworkParticipantServiceImpl::findAllNetworkParticipant() empty network participent found");
			throw new ResourceNotFoundException("No record found!");
		}
		return allNetworkParticipantData;
	}

	@Override
	public NetworkParticipant getOneNetworkParticipant(Integer id) {
		logger.debug("NetworkParticipantServiceImpl::getOneNetworkParticipant()");
		logger.info("NetworkParticipantServiceImpl::getOneNetworkParticipant()");

		try {
			logger.error("NetworkParticipantServiceImpl::getOneNetworkParticipant()");
			return networkParticipantRepository.findById(id).get();
		} catch (NoSuchElementException e) {
			throw new ResourceNotFoundException("Network Participant id does not exists!");
		}

	}

	@Override
	public void deleteNetworkParticipant(Integer id) {
		logger.debug("NetworkParticipantServiceImpl::deleteNetworkParticipant()");
		logger.info("NetworkParticipantServiceImpl::deleteNetworkParticipant()");

		this.getOneNetworkParticipant(id);
		networkParticipantRepository.deleteById(id);
	}

	@Override
	public Object lookupTest(LookupDto subscriber) {
		logger.info("NetworkParticipantServiceImpl::lookup()");
		ListofSubscribers listsub = new ListofSubscribers();
		List<SubscriberDto> listofAllRecords = new ArrayList<SubscriberDto>();
		if(Boolean.TRUE.equals(cityFilter)) {
			List<Object[]> subscribers = networkParticipantRepository.lookUpByCity(subscriber.getStatus(), subscriber.getDomain(), subscriber.getCountry(), subscriber.getCity());
			for (Object[] sub : subscribers) {
				mapToSubscriberTest(listofAllRecords,sub,true);
			}
		}
		else{
			List<Object[]> subscribers = networkParticipantRepository.lookUpByWithoutCity(subscriber.getStatus(), subscriber.getDomain(), subscriber.getCountry());
			for (Object[] sub : subscribers) {
				mapToSubscriberTest(listofAllRecords,sub,true);
			}
		}
		listsub.setMessage(listofAllRecords);
		return listsub;
	}


	@Override
	public Object lookup(LookupDto subscriber) {
		logger.info("NetworkParticipantServiceImpl::lookup()");
		ListofSubscribers listsub = new ListofSubscribers();
		List<SubscriberDto> listofAllRecords = new ArrayList<SubscriberDto>();
		List<NetworkParticipant> findAllRecords = this.findAllNetworkParticipant();
		for (NetworkParticipant networkParticipant : findAllRecords) {
			List<NetworkRole> networkrole = networkParticipant.getNetworkrole();
			for (NetworkRole role : networkrole) {
				ParticipantKey participantkey = role.getParticipantKey();
				List<OperatingRegion> operatingregions = role.getOperatingregion();
				if (participantkey != null&&operatingregions!=null) {
					for (OperatingRegion opr : operatingregions) {
						if (Boolean.TRUE.equals(cityFilter)) {
							extractSubscribersBasedOnConditionPassed(opr.getCity().getStdCode().equalsIgnoreCase(subscriber.getCity())
									&& opr.getCountry().equalsIgnoreCase(subscriber.getCountry())
									&& role.getStatus().getName().equalsIgnoreCase(subscriber.getStatus())
									&& role.getDomain().getCode().equalsIgnoreCase(subscriber.getDomain()),listofAllRecords, networkParticipant, role, participantkey, opr, true);
						}
						else {
							extractSubscribersBasedOnConditionPassed(opr.getCountry().equalsIgnoreCase(subscriber.getCountry())
									&& role.getStatus().getName().equalsIgnoreCase(subscriber.getStatus())
									&& role.getDomain().getCode().equalsIgnoreCase(subscriber.getDomain()), listofAllRecords, networkParticipant, role, participantkey, opr, true);
						}

					}
				}
			}
		}

		listsub.setMessage(listofAllRecords);
		return listsub;
	}

	private void extractSubscribersBasedOnConditionPassed(boolean opr, List<SubscriberDto> listofAllRecords, NetworkParticipant networkParticipant, NetworkRole role, ParticipantKey participantkey, OperatingRegion opr1, boolean check) {
		if (opr) {
			mapToSubscriber(listofAllRecords, networkParticipant, role, participantkey, opr1, check);
		}
	}


	@Override
	public Object search(String stringSearchDto, @RequestHeader Map<String, String> headers, boolean isInternal) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException {
		SearchDto searchDto = null;

		if(!isInternal) {
			logger.info("{} | Authorization |", headers.get("authorization"));
			if (!headers.containsKey("authorization") && Boolean.TRUE.equals(isHeaderEnabled)) {
				throw new AuthHeaderNotFoundError(GlobalConstants.AUTH_HEADER_NOT_FOUND);
			}
			HeaderDTO authParams = crypt.extractAuthorizationParams("authorization", headers);
			if(Boolean.TRUE.equals(isHeaderEnabled)) {
				verifyHeaders(stringSearchDto, authParams);
			}
		}

			List<SubscriberDto> listofAllRecords = new ArrayList<>();
		List<NetworkParticipant> allRecords = this.findAllNetworkParticipant();
	logger.debug("195 NetworkParticipantServiceImpl search() allRecords :: {} isInternal :: {} ",allRecords.size(),isInternal);
		try {
			searchDto = objectMapper.readValue(stringSearchDto, SearchDto.class);
			if(Boolean.TRUE.equals(cityFilter)) {
				filterParticipants(searchDto, listofAllRecords,allRecords);
			}
			else{
				filterParticipantsExcludingCity(searchDto, listofAllRecords,allRecords);
			}
		} catch (Exception e) {
			logger.error("NetworkParticipantServiceImpl::search::{}", e.getMessage());
		}
		if (listofAllRecords.isEmpty()) {
			throw new ResourceNotFoundException("No record found!");
		}

		return listofAllRecords;

	}

	@Override
	public Object searchTest(String stringSearchDto, @RequestHeader Map<String, String> headers, boolean isInternal) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException {
		SearchDto searchDto = null;

		if(!isInternal) {
			logger.info("{} | Authorization |", headers.get("authorization"));
			if (!headers.containsKey("authorization") && Boolean.TRUE.equals(isHeaderEnabled)) {
				throw new AuthHeaderNotFoundError(GlobalConstants.AUTH_HEADER_NOT_FOUND);
			}
			HeaderDTO authParams = crypt.extractAuthorizationParams("authorization", headers);
			if(Boolean.TRUE.equals(isHeaderEnabled)) {
				verifyHeaders(stringSearchDto, authParams);
			}
		}

		List<SubscriberDto> listofAllRecords = new ArrayList<>();
		logger.debug("195 NetworkParticipantServiceImpl search() allRecords :: {} isInternal :: {} ",isInternal);
		try {
			searchDto = objectMapper.readValue(stringSearchDto, SearchDto.class);
			if(Boolean.TRUE.equals(cityFilter)) {
				filterParticipantsTest(searchDto, listofAllRecords);
			}
			else{
				filterParticipantsExcludingCityTest(searchDto, listofAllRecords);
			}
		} catch (Exception e) {
			logger.error("NetworkParticipantServiceImpl::search::{}", e.getMessage());
		}
		if (listofAllRecords.isEmpty()) {
			throw new ResourceNotFoundException("No record found!");
		}

		return listofAllRecords;

	}



	private void filterParticipantsTest(SearchDto searchDto, List<SubscriberDto> listofAllRecords) {
	 List<Object[]> subscriberDtos=networkParticipantRepository.findByCity(searchDto.getSubscriberId(),searchDto.getType(),searchDto.getDomain(),searchDto.getCountry(),searchDto.getCity(),searchDto.getPublicKeyId(),searchDto.getSubscriberUrl());
		for (Object[] sub : subscriberDtos) {
			mapToSubscriberTest(listofAllRecords,sub,true);
		}
		}

	private void filterParticipantsExcludingCityTest(SearchDto searchDto, List<SubscriberDto> listofAllRecords) {
		List<Object[]> subscriberDtos=networkParticipantRepository.findByExcludingCity(searchDto.getSubscriberId(),searchDto.getType(),searchDto.getDomain(),searchDto.getCountry(),searchDto.getPublicKeyId(),searchDto.getSubscriberUrl());
		for (Object[] sub : subscriberDtos) {
		 mapToSubscriberTest(listofAllRecords,sub,false);
		}
	}


	private void filterParticipants(SearchDto searchDto, List<SubscriberDto> listofAllRecords, List<NetworkParticipant> findAllRecords) {
		for (NetworkParticipant networkParticipant : findAllRecords) {
			List<NetworkRole> networkrole = networkParticipant.getNetworkrole();
			for (NetworkRole role : networkrole) {
				List<OperatingRegion> operatingregions = role.getOperatingregion();
				ParticipantKey participantkey = role.getParticipantKey();
				if (role.getParticipantKey() != null && operatingregions!=null) {
					for (OperatingRegion opr : operatingregions) {
						if (role.getSubscriberid().equalsIgnoreCase(searchDto.getSubscriberId())
								&& role.getSubscriberurl().equalsIgnoreCase(searchDto.getSubscriberUrl())
								&& role.getType().equalsIgnoreCase(searchDto.getType())
								&& role.getDomain().getCode().equalsIgnoreCase(searchDto.getDomain())
								&&  opr.getCity().getStdCode().equalsIgnoreCase(searchDto.getCity())
								&& opr.getCountry().equalsIgnoreCase(searchDto.getCountry())&&participantkey.getUniqueKeyId().equals(searchDto.getPublicKeyId())) {
							mapToSubscriber(listofAllRecords, networkParticipant, role, participantkey, opr,true);
						}
					}
				}
			}
		}
	}

	private void filterParticipantsExcludingCity(SearchDto searchDto, List<SubscriberDto> listofAllRecords, List<NetworkParticipant> findAllRecords) {
		for (NetworkParticipant networkParticipant : findAllRecords) {
			List<NetworkRole> networkrole = networkParticipant.getNetworkrole();
			for (NetworkRole role : networkrole) {
				List<OperatingRegion> operatingregions = role.getOperatingregion();

				ParticipantKey participantkey = role.getParticipantKey();
				if (role.getParticipantKey() != null && operatingregions!=null) {
					for (OperatingRegion opr : operatingregions) {
						if (role.getSubscriberid().equalsIgnoreCase(searchDto.getSubscriberId())
								&& role.getSubscriberurl().equalsIgnoreCase(searchDto.getSubscriberUrl())
								&& role.getType().equalsIgnoreCase(searchDto.getType())
								&& role.getDomain().getCode().equalsIgnoreCase(searchDto.getDomain())
								&& opr.getCountry().equalsIgnoreCase(searchDto.getCountry())
								&&participantkey.getUniqueKeyId().equals(searchDto.getPublicKeyId())) {
							mapToSubscriber(listofAllRecords, networkParticipant, role, participantkey, opr,false);
						}
					}
				}
			}
		}
	}

	private void verifyHeaders(String stringSearchDto, HeaderDTO authParams) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException, SignatureException, InvalidKeySpecException {
			Map<String, String> keyIdMap = crypt.extarctKeyId(authParams.getKeyId());
			ParticipantKey headerparticipantKey = participantKeyRepository.findByUniqueKeyId(keyIdMap.get("pub_key_id"));
			String hashedSigningString = crypt.generateBlakeHash(
					crypt.getSigningString(Long.parseLong(authParams.getCreated()), Long.parseLong(authParams.getExpires()), stringSearchDto));
			boolean headerVerificationResult = crypt.verifySignature(hashedSigningString, authParams.getSignature(), "Ed25519", Crypt.getPublicKey("Ed25519", Base64.getDecoder().decode(headerparticipantKey.getEncrPublicKey())));

			if (!headerVerificationResult) {
				logger.error("Header verification failed.");
				throw new HeaderVerificationFailedError(GatewayError.HEADER_VERFICATION_FAILED.getMessage());
			}
	}


	private void mapToSubscriberTest(List<SubscriberDto> listofAllRecords,Object[] sub,boolean check){
			SubscriberDto dto = new SubscriberDto();
			dto.setSubscriber_id((String) sub[0]);
			dto.setParticipant_id((String) sub[1]);
			dto.setCountry((String) sub[2]);
			dto.setCity((String) sub[3]);
			dto.setDomain((String) sub[4]);
			dto.setEncr_public_key((String) sub[5]);
			dto.setStatus((String) sub[7]);
			dto.setType((String) sub[8]);
			dto.setPubKeyId((String) sub[9]);
		    dto.setValid_to((String) sub[10]);
			dto.setSubscriber_url((String)sub[11]);
		    if(check)
			dto.setSigning_public_key((String)sub[12]);
		    listofAllRecords.add(dto);

		}


	private void mapToSubscriber(List<SubscriberDto> listofAllRecords, NetworkParticipant networkParticipant,
			NetworkRole role, ParticipantKey participantkey, OperatingRegion opr,boolean check) {
		SubscriberDto subscriberData = new SubscriberDto();
		subscriberData.setDomain(role.getDomain().getCode());
		subscriberData.setCity(opr.getCity().getStdCode());
		subscriberData.setCountry(opr.getCountry());
		subscriberData.setParticipant_id(networkParticipant.getParticipantId());
		subscriberData.setStatus(role.getStatus().getName());
		subscriberData.setSubscriber_id(role.getSubscriberid());
		subscriberData.setSubscriber_url(role.getSubscriberurl());
		subscriberData.setType(role.getType());
		subscriberData.setEncr_public_key(participantkey.getEncrPublicKey());
		subscriberData.setPubKeyId(participantkey.getUniqueKeyId());
		if(check)
		subscriberData.setSigning_public_key(participantkey.getSigningPublicKey());
		subscriberData.setValid_from(participantkey.getValidFrom());
		subscriberData.setValid_to(participantkey.getValidTo());
		listofAllRecords.add(subscriberData);
	}


	@Override
	public Object GatewaySearch(SearchDto searchDto) {
		logger.info("NetworkParticipantServiceImpl::lookup()");
		List<NetworkParticipant> findAllRecords = this.findAllNetworkParticipant();
		SubscriberDto subscriberData = new SubscriberDto();
		for (NetworkParticipant networkParticipant : findAllRecords) {
			List<NetworkRole> networkrole = networkParticipant.getNetworkrole();
			for (NetworkRole role : networkrole) {
				ParticipantKey participantkey = role.getParticipantKey();
				List<OperatingRegion> operatingregions = role.getOperatingregion();
				if (participantkey != null && operatingregions != null) {
					for (OperatingRegion opr : operatingregions) {

						if (role.getSubscriberid().equalsIgnoreCase(searchDto.getSubscriberId())
								&& role.getStatus().getName().equalsIgnoreCase(searchDto.getStatus())
								&& role.getType().equalsIgnoreCase(searchDto.getType())
								&& participantkey.getUniqueKeyId().equalsIgnoreCase(searchDto.getPublicKeyId())) {
							subscriberData.setDomain(role.getDomain().getCode());
							subscriberData.setCity(opr.getCity().getStdCode());
							subscriberData.setCountry(opr.getCountry());
							subscriberData.setParticipant_id(networkParticipant.getParticipantId());
							subscriberData.setStatus(role.getStatus().getName());
							subscriberData.setSubscriber_id(role.getSubscriberid());
							subscriberData.setSubscriber_url(role.getSubscriberurl());
							subscriberData.setType(role.getType());
							subscriberData.setEncr_public_key(participantkey.getEncrPublicKey());
							subscriberData.setPubKeyId(participantkey.getUniqueKeyId());
							subscriberData.setSigning_public_key(participantkey.getSigningPublicKey());
							subscriberData.setValid_from(participantkey.getValidFrom());
							subscriberData.setValid_to(participantkey.getValidTo());
						}
					}
				}
			}
		}
		return subscriberData;
	}
}
