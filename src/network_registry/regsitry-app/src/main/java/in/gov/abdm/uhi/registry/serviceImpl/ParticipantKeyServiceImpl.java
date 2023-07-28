package in.gov.abdm.uhi.registry.serviceImpl;

import java.security.KeyPair;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

import in.gov.abdm.uhi.registry.util.Crypt;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import in.gov.abdm.uhi.registry.dto.ParticipantKeyDto;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;
import in.gov.abdm.uhi.registry.exception.InvalidDateTimeException;
import in.gov.abdm.uhi.registry.exception.RecordAlreadyExists;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.repository.NetworkParticipantRepository;
import in.gov.abdm.uhi.registry.repository.NetworkRoleRepository;
import in.gov.abdm.uhi.registry.repository.ParticipantKeyRepository;
import in.gov.abdm.uhi.registry.service.ParticipantKeyService;
import in.gov.abdm.uhi.registry.util.DateTimeVailidater;

@Service
public class ParticipantKeyServiceImpl implements ParticipantKeyService {
	private static final Logger logger = LogManager.getLogger(ParticipantKeyServiceImpl.class);
	private static Random rnd;
	private static PrivateKey PRIVATE_KEY;
	private static PublicKey PUBLIC_KEY;
	@Autowired
	private ParticipantKeyRepository participantKeyRepository;
	@Autowired
	NetworkParticipantRepository networkParticipantRepository;
	@Autowired
	private NetworkRoleRepository networkRoleRepository;
	@Autowired
	Crypt cr;

	@Override
	public ParticipantKey saveParticipantKey(ParticipantKeyDto participantKeyDto) throws NoSuchAlgorithmException {
		logger.info("ParticipantKeyServiceImpl::saveParticipantKey()");
		NetworkRole networkRole = null;
		ParticipantKey extractParticipantKey = null;
		ParticipantKey savedData = null;
		ParticipantKey participantKey=null;

		try {
			networkRole = networkRoleRepository.findById(participantKeyDto.getNetworkRoleId()).get();
			
		} catch (NoSuchElementException e) {
			throw new ResourceNotFoundException("Network participant id does not exists!");
		}
		boolean valid = DateTimeVailidater.isValid(participantKeyDto.getValidFrom().trim(),
				participantKeyDto.getValidTo().trim());
		if (valid) {
			if (networkRole != null) {
				List<NetworkRole> roleData = networkRoleRepository
						.findBySubscriberid(participantKeyDto.getSubscriberid());
				List<ParticipantKey> keyList = roleData.stream().map(x -> x.getParticipantKey())
						.collect(Collectors.toList());
				if(! keyList.isEmpty()) {
				 participantKey = keyList.get(0);
				}
				
				if (participantKey != null) {
					ParticipantKey paticipantKeyData = new ParticipantKey();
					networkRole.setParticipantKey(participantKey);
					paticipantKeyData.setNetworkrole(networkRole);
					paticipantKeyData.setEncrPublicKey(participantKey.getEncrPublicKey());
					paticipantKeyData.setSigningPublicKey(participantKey.getSigningPublicKey());
					paticipantKeyData.setUniqueKeyId(participantKeyDto.getUniqueKeyId());
					paticipantKeyData.setNetworkrole(networkRole);
					paticipantKeyData.setValidFrom(participantKeyDto.getValidFrom());
					paticipantKeyData.setValidTo(participantKeyDto.getValidTo());
					try {
					savedData = participantKeyRepository.save(paticipantKeyData);
					}catch (DataIntegrityViolationException e) {
					throw new RecordAlreadyExists("Unique key id already exist!");
					}
				}
				 else {
					extractParticipantKey = extractParticipantKey(participantKeyDto, networkRole);
					 networkRole.setParticipantKey(extractParticipantKey);
					savedData = participantKeyRepository.save(extractParticipantKey);
				}

			}
		} else {
			logger.error("ParticipantKeyServiceImpl class");
			throw new InvalidDateTimeException("Valid from should be lesss than valid to!");
		}
		return savedData;
	}

	@Override
	public ParticipantKey updateParticipantKey(ParticipantKey participantKey) {
		logger.info("ParticipantKeyServiceImpl::updateParticipantKey()");
		ParticipantKey participantKeyData = this.getOneParticipantKey(participantKey.getId());
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
		LocalDate currentDate = LocalDate.now();
		logger.info("ParticipantKey class:updateParticipantKey(ParticipantKey participantKey)" + participantKey);
		LocalDate validFrom = LocalDate.parse(participantKey.getValidFrom(), formatter);
		LocalDate ValidTo = LocalDate.parse(participantKey.getValidTo(), formatter);
		if (ValidTo.isAfter(currentDate.minusDays(1)) && validFrom.isBefore(ValidTo)) {
			participantKeyData.setUniqueKeyId(participantKey.getUniqueKeyId());
			participantKeyData.setValidFrom(participantKey.getValidFrom());
			participantKeyData.setValidTo(participantKey.getValidTo());
			return participantKeyRepository.save(participantKeyData);
		} else {
			logger.error("ParticipantKeyServiceImpl class:updateParticipantKey(ParticipantKey participantKey)"
					+ participantKey);
			throw new InvalidDateTimeException("Invalid valid to and Valid from date !");
		}

	}

	@Override
	public List<ParticipantKey> findAllParticipantKey() {
		logger.info("ParticipantKeyServiceImpl::findAllParticipantKey()");
		List<ParticipantKey> participantKeyDataList = participantKeyRepository.findAll();
		return participantKeyDataList;
	}

	@Override
	public ParticipantKey getOneParticipantKey(Integer id) {
		logger.info("ParticipantKeyServiceImpl::getOneParticipantKey()");
		try {
			return participantKeyRepository.findById(id).get();
		} catch (Exception e) {
			throw new ResourceNotFoundException("Participant key id does not exists!");
		}

	}

	@Override
	public void deleteParticipantKey(Integer id) {
		logger.info("ParticipantKeyServiceImpl::deleteParticipantKey()");
		ParticipantKey oneParticipantKey = this.getOneParticipantKey(id);
		participantKeyRepository.delete(oneParticipantKey);
	}

	public static String getSaltString() {
		logger.info("ParticipantKeyServiceImpl::getSaltString()");
		try {
			rnd = SecureRandom.getInstanceStrong();
		} catch (NoSuchAlgorithmException e) {
			logger.info("SubscriberServiceImpl class:" + e);
		}
		String SALTCHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
		StringBuilder salt = new StringBuilder();
		while (salt.length() < 18) {
			int index = (int) (rnd.nextFloat() * SALTCHARS.length());
			salt.append(SALTCHARS.charAt(index));
		}
		return salt.toString();

	}

	public ParticipantKey extractParticipantKey(ParticipantKeyDto participantKey, NetworkRole networkrole) throws NoSuchAlgorithmException {

		Map<String, String> stringStringMap = cr.generateDerKeyPairs();
		ParticipantKey parKey = new ParticipantKey();
		parKey.setEncrPublicKey(stringStringMap.get("public"));
		parKey.setSigningPublicKey(stringStringMap.get("private"));
		parKey.setValidFrom(participantKey.getValidFrom());
		parKey.setValidTo(participantKey.getValidTo());
		parKey.setUniqueKeyId(participantKey.getUniqueKeyId());
	   parKey.setNetworkrole(networkrole);
		DateTimeVailidater.isValid(participantKey.getValidFrom(), participantKey.getValidTo());
		return parKey;
	}

}
