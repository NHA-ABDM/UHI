package in.gov.abdm.uhi.hspa.repo;

import java.util.List;

import in.gov.abdm.uhi.hspa.models.UserTokenModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface UserTokenRepository extends JpaRepository<UserTokenModel, String>{

	List<UserTokenModel> findByUserName(String userName);
	


}
