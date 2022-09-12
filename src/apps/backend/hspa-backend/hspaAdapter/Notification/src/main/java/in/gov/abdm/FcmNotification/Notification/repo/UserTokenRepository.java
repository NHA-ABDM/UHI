package in.gov.abdm.FcmNotification.Notification.repo;

import in.gov.abdm.FcmNotification.Notification.model.UserTokenModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface UserTokenRepository extends JpaRepository<UserTokenModel, String>{

	List<UserTokenModel> findByUserName(String userName);
	Integer deleteByUserId(String userId);


}
