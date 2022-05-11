package in.gov.abdm.uhi.registry.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.zaxxer.hikari.util.SuspendResumeLock;

import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.entity.Subscriber;
import in.gov.abdm.uhi.registry.exception.InvalidDateTimeException;
import in.gov.abdm.uhi.registry.exception.RecordAlreadyExists;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.repository.SubscriberRepository;
import in.gov.abdm.uhi.registry.service.SubscriberService;
import in.gov.abdm.uhi.registry.util.DateTimeVailidater;

@Service
//@Qualifier(value="subscriberRepository")
public class SubscriberServiceImpl implements SubscriberService {
	@Autowired
	SubscriberRepository subscriberRepository;

	@Override
	public Subscriber addSubscriber(Subscriber subscriber) {
		Subscriber subscriberData = null;
		boolean valid = DateTimeVailidater.isValid(subscriber.getValidFrom().trim(),subscriber.getValidTo().trim());
		
		if (this.findSubscriber(subscriber.getSubscriberId()) != null) {
			throw new RecordAlreadyExists("Subscriber already exists");
		} else if(valid){
			//subscriberData.setStatus(status);
			subscriber.setStatus("INITIATED");
			subscriberData = subscriberRepository.save(subscriber);
			
		}else {
			System.out.println("Valid from should be lesss than valid to!");
			throw new InvalidDateTimeException("Valid from should be lesss than valid to!");
		}
		return subscriberData;
	}
	

	@Override
	public Subscriber updateSubscriber(Subscriber subscriber) {
		Subscriber subscriberData = this.findSubscriber(subscriber.getSubscriberId().trim());
		System.out.println("_____"+subscriberData);
		if (subscriberData == null) {
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}

		subscriberData.setCity(subscriber.getCity());
		subscriberData.setCountry(subscriber.getCountry());
		subscriberData.setUpdaterUser(subscriber.getUpdaterUser());
		subscriberData.setCreaterUser(subscriber.getCreaterUser());
		subscriberData.setDomain(subscriber.getDomain());
		subscriberData.setEncrPublicKey(subscriber.getPubKeyId());
		subscriberData.setParticipantId(subscriber.getParticipantId());
		subscriberData.setPubKeyId(subscriber.getPubKeyId());
		subscriberData.setRadius(subscriber.getRadius());
		subscriberData.setSigningPublicKey(subscriber.getSigningPublicKey());
		subscriberData.setStatus(subscriber.getStatus());
		subscriberData.setType(subscriber.getType());
		subscriberData.setUniqueKeyId(subscriber.getUniqueKeyId());
		subscriberData.setUrl(subscriber.getUrl());
		subscriberData.setValidFrom(subscriber.getValidFrom());
		subscriberData.setValidTo(subscriber.getValidTo());
		return subscriberRepository.save(subscriberData);
	}

	@Override
	public Subscriber findSubscriber(String subscriberId) {
		return subscriberRepository.findBySubscriberId(subscriberId);
	}
	

	@Override
	public List<Subscriber> lookup(LookupDto subscriber) {
		List<Subscriber> subscriberData = this.findByStatusAndTypeAndDomainAndCountryAndCity(
				subscriber.getStatus(), subscriber.getType(), subscriber.getDomain(), subscriber.getCountry(),
				subscriber.getCity());
		return subscriberData;
	}

	@Override
	public List<Subscriber> findByStatusAndTypeAndDomainAndCountryAndCity(String status, String type,
			String domain, String country, String city) {
		List<Subscriber> subscriberData = subscriberRepository
				.findByStatusAndTypeAndDomainAndCountryAndCity(status, type, domain, country, city);
		if (subscriberData == null) {
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}
		return subscriberData;
	}


	@Override
	public List<Subscriber> findAll() {
		return subscriberRepository.findAll();
	}


	@Override
	public Integer deleteSubscriber(String subscriberId) {
		Subscriber subscriberData = this.findSubscriber(subscriberId.trim());
		if(subscriberData==null) {
			throw new ResourceNotFoundException("Subscriber does not exists!");
		}
		return subscriberRepository.deleteBySubscriberId(subscriberId.trim());
	}

}
