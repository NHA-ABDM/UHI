package in.gov.abdm.uhi.EUABookingService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.UserToken;

@Repository
public interface UserTokenRepository extends JpaRepository<UserToken, String>{

	List<UserToken> findByUserName(String userName);
	Integer deleteByUserId(String userId);


}
