package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long>{
	
	User findByHealthIdNumber(String abha_id);

    User findById(String abhaAddress);
}
