package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.UserToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserTokenRepository extends JpaRepository<UserToken, String>{

	List<UserToken> findByUserName(String userName);
	


}
