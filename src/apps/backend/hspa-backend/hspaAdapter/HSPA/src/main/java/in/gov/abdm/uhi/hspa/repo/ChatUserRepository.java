package in.gov.abdm.uhi.hspa.repo;

import in.gov.abdm.uhi.hspa.models.ChatUserModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ChatUserRepository extends JpaRepository<ChatUserModel, String>{

	List<ChatUserModel> findByUserId(String userId);
	


}
