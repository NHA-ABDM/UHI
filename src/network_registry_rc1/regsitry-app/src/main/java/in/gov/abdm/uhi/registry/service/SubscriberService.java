package in.gov.abdm.uhi.registry.service;


import java.util.List;

import in.gov.abdm.uhi.registry.dto.KeyDto;
import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.SubscribeResponseDto;
import in.gov.abdm.uhi.registry.dto.SubscriberDto;
import in.gov.abdm.uhi.registry.entity.ListofSubscribers;
import in.gov.abdm.uhi.registry.entity.Subscriber;

public interface SubscriberService {
	 public SubscriberDto  addSubscriber(SubscriberDto subscriber);
	 public SubscriberDto updateSubscriber(SubscriberDto subscriber);
	 public SubscriberDto findSubscriber(Integer id);
	 public String lookup(LookupDto subscriber);
	 public List<Subscriber> findByStatusAndDomainAndCountryAndCity(String status,
				String domain, String country,String city);
	 public List<SubscriberDto> findAll();
	 public void deleteSubscriber(Integer id);
	 public SubscribeResponseDto changeStatus(Integer id,String status);
	 
	 public List<KeyDto> getSubscriberKeys(String subscriberId);
	 
}
