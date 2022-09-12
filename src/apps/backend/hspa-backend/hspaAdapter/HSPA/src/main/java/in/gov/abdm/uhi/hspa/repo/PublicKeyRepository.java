package in.gov.abdm.uhi.hspa.repo;

import in.gov.abdm.uhi.hspa.models.PublicKeyModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface PublicKeyRepository extends JpaRepository<PublicKeyModel, String>{

	List<PublicKeyModel> findByUserName(String userName);
	


}
