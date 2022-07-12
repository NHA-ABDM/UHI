package in.gov.abdm.uhi.registry.serviceImpl;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Random;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.registry.dto.KeyDto;
import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.SubscribeResponseDto;
import in.gov.abdm.uhi.registry.dto.SubscriberDto;
import in.gov.abdm.uhi.registry.entity.ListofSubscribers;
import in.gov.abdm.uhi.registry.entity.Subscriber;
import in.gov.abdm.uhi.registry.exception.InvalidDateTimeException;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.repository.SubscriberRepository;
import in.gov.abdm.uhi.registry.security.Crypt;
import in.gov.abdm.uhi.registry.service.SubscriberService;
import in.gov.abdm.uhi.registry.util.DateTimeVailidater;

@Service
public class SubscriberServiceImpl implements SubscriberService {
	private String PRIVAT_EKEY = null;
	private String PUBLIC_KEY = null;
	@Autowired
	SubscriberRepository subscriberRepository;
	private static final Logger logger = LogManager.getLogger(SubscriberServiceImpl.class);
	ModelMapper mapper = new ModelMapper();

	@Override
	public SubscriberDto addSubscriber(SubscriberDto subscriber) {
		Subscriber subscriberData = null;
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",Locale.ENGLISH);
		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.ENGLISH);
		/*String validFromstr=null;
		String validTostr=null;
		try {
			LocalDate validFrom = LocalDate.parse(subscriber.getValidFrom(), formatter);
			validFromstr = outputFormatter.format(validFrom);
			LocalDate validTo = LocalDate.parse(subscriber.getValidTo(), formatter);
			validTostr = outputFormatter.format(validTo);
			
		}catch (Exception e) {
			
		}*/
		
		boolean valid = DateTimeVailidater.isValid(subscriber.getValidFrom().trim(), subscriber.getValidTo().trim());
		if (valid) {
			logger.info("SubscriberServiceImpl class:addSubscriber(Subscriber subscriber)" + subscriber);
			logger.debug("SubscriberServiceImpl class:addSubscriber(Subscriber subscriber)" + subscriber);
			Crypt cr = new Crypt();
			String challangeString = this.getSaltString();
			
			try {
				Map<String, String> keyGenerator = cr.keyGenerator("BC");
				PUBLIC_KEY = keyGenerator.get("publicKey");
				PRIVAT_EKEY = keyGenerator.get("privateKey");
			} catch (JsonProcessingException e) {
				e.printStackTrace();
			}
			//subscriber.setValidFrom(validFromstr);
			//subscriber.setValidTo(validTostr);
			subscriber.setChallangeString(challangeString);
			subscriber.setSigningPublicKey(PUBLIC_KEY);
			subscriber.setEncrPublicKey(PRIVAT_EKEY);
			subscriber.setStatus("INITIATED");
			subscriberData = mapper.map(subscriber, Subscriber.class);
		    subscriberData = subscriberRepository.save(subscriberData);
			

		} else {
			logger.error("SubscriberServiceImpl class:addSubscriber(Subscriber subscriber)" + subscriber);
			System.out.println("Valid from should be lesss than valid to!");
			throw new InvalidDateTimeException("Valid from should be lesss than valid to!");
		}
		return   mapper.map(subscriberData,SubscriberDto.class);
	}

	@Override
	public SubscriberDto updateSubscriber(SubscriberDto subscriber) {
		logger.info("SubscriberServiceImpl class:updateSubscriber(Subscriber subscriber)" + subscriber);
		SubscriberDto subscriberData = this.findSubscriber(subscriber.getId());
		System.out.println("_____" + subscriberData);
		if (subscriberData == null) {
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}
		subscriberData.setSubscriberId(subscriber.getSubscriberId());
		subscriberData.setCity(subscriber.getCity());
		subscriberData.setCountry(subscriber.getCountry());
		subscriberData.setUpdaterUser(subscriber.getUpdaterUser());
		subscriberData.setCreaterUser(subscriber.getCreaterUser());
		subscriberData.setDomain(subscriber.getDomain());
		subscriberData.setEncrPublicKey(subscriberData.getEncrPublicKey());
		subscriberData.setParticipantId(subscriber.getParticipantId());
		subscriberData.setSigningPublicKey(subscriberData.getSigningPublicKey());
		subscriberData.setStatus(subscriberData.getStatus());
		subscriberData.setPubKeyId(subscriber.getPubKeyId());
		subscriberData.setRadius(subscriber.getRadius());
		subscriberData.setType(subscriber.getType());
		subscriberData.setUniqueKeyId(subscriber.getUniqueKeyId());
		subscriberData.setUrl(subscriber.getUrl());
		subscriberData.setValidFrom(subscriber.getValidFrom());
		subscriberData.setValidTo(subscriber.getValidTo());
		logger.debug("SubscriberServiceImpl class:updateSubscriber(Subscriber subscriber)" + subscriber);
		Subscriber data = mapper.map(subscriberData,Subscriber.class);
		Subscriber updatedSubscriberData = subscriberRepository.save(data);
		System.out.println("________Updated______"+updatedSubscriberData);
		return mapper.map(updatedSubscriberData,SubscriberDto.class);
	}

	@Override
	public SubscriberDto findSubscriber(Integer id) {

		try {
			 Subscriber subscriber = subscriberRepository.findById(id).get();
			 return mapper.map(subscriber,SubscriberDto.class);

		} catch (NoSuchElementException e) {
			logger.error("SubscriberServiceImpl class:updateSubscriber(Subscriber subscriber)");
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}
	}

	@Override
	public String lookup(LookupDto subscriber) {
		logger.info("SubscriberServiceImpl class:lookup()" + subscriber);
		List<Subscriber> subscriberData = this.findByStatusAndDomainAndCountryAndCity(
				subscriber.getStatus(), subscriber.getDomain(), subscriber.getCountry(),
				subscriber.getCity());
		ListofSubscribers listsub = new ListofSubscribers();
		listsub.setMessage(subscriberData);
		ObjectMapper objmapper = new ObjectMapper();
		String resp = null;
		try {
			resp = objmapper.writeValueAsString(listsub);
		} catch (JsonProcessingException e) {
			logger.error("SubscriberServiceImpl class:lookup()" + subscriber);
			e.printStackTrace();
		}
		System.out.println("RESP|" + resp);
		return resp;
	}

	@Override
	public List<Subscriber> findByStatusAndDomainAndCountryAndCity( String status,
			String domain, String country, String city) {
		System.out.println(status+""+domain+""+country+""+city);
		logger.info("SubscriberServiceImpl class:findByTypeAndStatusAndDomainAndCountryAndCity()");
		List<Subscriber> subscriberData = subscriberRepository
				.findByStatusAndDomainAndCountryAndCity(status,domain,country,city);
		//System.out.println();
		if (subscriberData.isEmpty()) {
			logger.error("SubscriberServiceImpl class:findByTypeAndStatusAndDomainAndCountryAndCity()");
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}
		return subscriberData;
	}

	@Override
	public  List<SubscriberDto> findAll() {
		 List<Subscriber> subscriberData = subscriberRepository.findAll();
		 List<SubscriberDto> dtos = entityToDto(subscriberData);
		
		 return dtos ;
	}

	private List<SubscriberDto> entityToDto(List<Subscriber> subscriberData) {
		List<SubscriberDto> dtos = subscriberData.stream()
				  .map(x -> mapper.map(x, SubscriberDto.class))
				  .collect(Collectors.toList());
		return dtos;
	}

	@Override
	public void deleteSubscriber(Integer id) {
		logger.info("SubscriberServiceImpl class:deleteSubscriber()" + id);
		SubscriberDto subscriberData = this.findSubscriber(id);
		if (subscriberData == null) {
			logger.error("SubscriberServiceImpl class:deleteSubscriber()" + id);
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}
		subscriberRepository.deleteById(id);
	}

	@Override
	public SubscribeResponseDto changeStatus(Integer id, String status) {
		logger.info("SubscriberServiceImpl class:changeStatus()" + id);
		String status2 = status.replace("\"", "");
		SubscriberDto SubscriberData = this.findSubscriber(id);
		SubscriberData.setStatus(status2);
		logger.debug("SubscriberServiceImpl class:changeStatus()" + id);
		Subscriber changedData = mapper.map(SubscriberData,Subscriber.class);
		subscriberRepository.save(changedData);
		return new SubscribeResponseDto(status2);
	}

	@Override
	public List<KeyDto> getSubscriberKeys(String subscriberId) {
		KeyDto keys = new KeyDto();
		List<KeyDto> keydto = new ArrayList<KeyDto>();
		List<Subscriber> subscriberData = subscriberRepository.findBySubscriberId(subscriberId);
		if (subscriberData.isEmpty()) {
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}

		for (Subscriber subscriber : subscriberData) {
			keys.setPrivateKey(subscriber.getEncrPublicKey());
			keys.setPublicKey(subscriber.getSigningPublicKey());
			keydto.add(keys);
		}
		System.out.println("keys" + keydto);
		return keydto;

	}
	
	public  static String getSaltString() {
        String SALTCHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        StringBuilder salt = new StringBuilder();
        Random rnd = new Random();
        while (salt.length() < 18) { // length of the random string.
            int index = (int) (rnd.nextFloat() * SALTCHARS.length());
            salt.append(SALTCHARS.charAt(index));
        }
        String saltStr = salt.toString();
        return saltStr;

    }

}
