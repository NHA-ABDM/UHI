package in.gov.abdm.uhi.registry.repository;

import java.util.List;

import javax.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;

import in.gov.abdm.uhi.registry.entity.Subscriber;
@Transactional
public interface SubscriberRepository extends JpaRepository<Subscriber, Integer> {
	public List<Subscriber> findByStatusAndTypeAndDomainAndCountryAndCity(String status, String type,
			String domain, String country, String city);

	public Subscriber findBySubscriberId(String subscriberId);
	public Integer deleteBySubscriberId(String subscriberId);

}
