package in.gov.abdm.uhi.EUABookingService.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.ChatUser;


@Repository
public interface ChatUserReposotory extends JpaRepository<ChatUser, String>{

	List<ChatUser> findByUserId(String userId);
	


}
