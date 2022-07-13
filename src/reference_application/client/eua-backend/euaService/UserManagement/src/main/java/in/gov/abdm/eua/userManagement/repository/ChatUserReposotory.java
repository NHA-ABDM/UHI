package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.ChatUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ChatUserReposotory extends JpaRepository<ChatUser, String>{

	List<ChatUser> findByUserId(String userId);
	


}
