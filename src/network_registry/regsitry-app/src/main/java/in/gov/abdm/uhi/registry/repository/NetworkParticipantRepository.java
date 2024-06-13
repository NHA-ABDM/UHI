package in.gov.abdm.uhi.registry.repository;

import javax.transaction.Transactional;

import in.gov.abdm.uhi.registry.dto.SubscriberDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.registry.entity.NetworkParticipant;

import java.util.List;

@Repository
@Transactional
public interface NetworkParticipantRepository extends JpaRepository<NetworkParticipant, Integer> {
	
	public NetworkParticipant findByParticipantId(String participantId);
	@Query(value="Select nr2.subscriber_id as id ,np.participant_id,or2.country,c.std_code," +
			"d.code,pk.encr_public_key,pk.valid_from,s.name,nr2.type,pk.unique_key_id,pk.valid_to," +
			"nr2.subscriber_url,pk.signing_public_key from network_participant np JOIN network_role nr2 on " +
			"nr2.participant_id =np.id join domain d on nr2.domain_id= d.id join operating_region or2" +
			" on nr2.id=or2.network_role_id join city c on or2.city_id=c.id join participant_key pk " +
			"on pk.networkrole_id =nr2.id join status s on nr2.status_id =s.id and " +
			"nr2.subscriber_id =:subscriberId and d.code=:domain and c.std_code =:city and " +
			"or2.country =:country and nr2.type=:type and pk.unique_key_id =:pubKeyId and nr2.subscriber_url =:subscriberUrl"
			,nativeQuery = true)
	List<Object[]> findByCity(@Param("subscriberId") String subscriberId,
							  @Param("type") String type,
							  @Param("domain") String domain,
							  @Param("country") String country,
							  @Param("city") String city,
							  @Param("pubKeyId") String pubKeyId,
							  @Param("subscriberUrl") String subscriberUrl
	                         );

	@Query(value="Select nr2.subscriber_id as id ,np.participant_id,or2.country,c.std_code,d.code," +
			"pk.encr_public_key,pk.valid_from,s.name,nr2.type,pk.unique_key_id,pk.valid_to," +
			"nr2.subscriber_url from network_participant np JOIN network_role nr2 on " +
			"nr2.participant_id =np.id join domain d on nr2.domain_id= d.id join operating_region or2 " +
			"on nr2.id=or2.network_role_id join city c on or2.city_id=c.id join participant_key pk " +
			"on pk.networkrole_id =nr2.id join status s on nr2.status_id =s.id and " +
			"nr2.subscriber_id =:subscriberId and d.code=:domain and or2.country =:country and " +
			"nr2.type=:type and pk.unique_key_id =:pubKeyId and nr2.subscriber_url =:subscriberUrl",nativeQuery = true)
	List<Object[]> findByExcludingCity(@Param("subscriberId") String subscriberId,
							           @Param("type") String type,
									   @Param("domain") String domain,
							           @Param("country") String country,
							           @Param("pubKeyId") String pubKeyId,
									   @Param("subscriberUrl") String subscriberUrl
	                                  );


	@Query(value="Select nr2.subscriber_id as id ,np.participant_id,or2.country,c.std_code," +
			"d.code,pk.encr_public_key,pk.valid_from,s.name,nr2.type,pk.unique_key_id,pk.valid_to," +
			"nr2.subscriber_url,pk.signing_public_key from network_participant np JOIN network_role nr2 on " +
			"nr2.participant_id =np.id join domain d on nr2.domain_id= d.id join operating_region or2" +
			" on nr2.id=or2.network_role_id join city c on or2.city_id=c.id join participant_key pk " +
			"on pk.networkrole_id =nr2.id join status s on nr2.status_id =s.id " +
			"and s.name=:status and d.code=:domain and c.std_code =:city and " + "or2.country =:country"
			,nativeQuery = true)
	List<Object[]> lookUpByCity(@Param("status") String status,
							  @Param("domain") String domain,
							  @Param("country") String country,
							  @Param("city") String city
	                           );


	@Query(value="Select nr2.subscriber_id as id ,np.participant_id,or2.country,c.std_code," +
			"d.code,pk.encr_public_key,pk.valid_from,s.name,nr2.type,pk.unique_key_id,pk.valid_to," +
			"nr2.subscriber_url,pk.signing_public_key from network_participant np JOIN network_role nr2 on " +
			"nr2.participant_id =np.id join domain d on nr2.domain_id= d.id join operating_region or2" +
			" on nr2.id=or2.network_role_id join city c on or2.city_id=c.id join participant_key pk " +
			"on pk.networkrole_id =nr2.id join status s on nr2.status_id =s.id " +
			"and s.name=:status and d.code=:domain and " + "or2.country =:country"
			,nativeQuery = true)
	List<Object[]> lookUpByWithoutCity(@Param("status") String status,
								       @Param("domain") String domain,
								       @Param("country") String country
	                                  );


}
