package in.gov.abdm.uhi.hspa.repo;

import in.gov.abdm.uhi.hspa.models.SharedKeyModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface SharedKeyRepository extends JpaRepository<SharedKeyModel, String>{

	List<SharedKeyModel> findByUserName(String userName);
	


}
