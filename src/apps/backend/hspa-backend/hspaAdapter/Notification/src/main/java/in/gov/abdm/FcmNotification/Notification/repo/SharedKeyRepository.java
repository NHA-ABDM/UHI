package in.gov.abdm.FcmNotification.Notification.repo;

import in.gov.abdm.FcmNotification.Notification.model.SharedKeyModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface SharedKeyRepository extends JpaRepository<SharedKeyModel, String>{

	List<SharedKeyModel> findByUserName(String userName);
	


}
