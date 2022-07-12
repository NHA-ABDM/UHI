package in.gov.abdm.uhi.registry.repository;

import java.util.List;

import javax.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;

import in.gov.abdm.uhi.registry.entity.Subscriber;
@Transactional
public interface SubscriberRepository extends JpaRepository<Subscriber, Integer> {
	public List<Subscriber> findByStatusAndDomainAndCountryAndCity(String staus,
			String domain, String country, String city);

	public List<Subscriber> findBySubscriberId(String subscriberId);
	public Integer deleteBySubscriberId(String subscriberId);

}
