package in.gov.abdm.uhi.EUABookingService.repository;

import java.util.List;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.SharedKey;


@Repository
public interface SharedKeyRepository extends JpaRepository<SharedKey, String>{

	List<SharedKey> findByUserName(String userName);
	


}
