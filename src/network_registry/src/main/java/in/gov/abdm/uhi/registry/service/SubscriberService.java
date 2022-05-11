package in.gov.abdm.uhi.registry.service;


import java.util.List;

import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.entity.Subscriber;

public interface SubscriberService {
	 public Subscriber  addSubscriber(Subscriber subscriber);
	 public Subscriber updateSubscriber(Subscriber subscriber);
	 public Subscriber findSubscriber(String subscriber_id);
	 public List<Subscriber> lookup(LookupDto subscriber);
	 public List<Subscriber> findByStatusAndTypeAndDomainAndCountryAndCity(String status, String type,
				String domain, String country,String city);
	 public List<Subscriber> findAll();
	 public Integer deleteSubscriber(String subscriberId);
}
