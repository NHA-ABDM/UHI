package in.gov.abdm.FcmNotification.Notification.repo;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.FcmNotification.Notification.model.SharedKey;


@Repository
public interface SharedKeyRepository extends JpaRepository<SharedKey, String>{

	List<SharedKey> findByUserName(String userName);
	


}
