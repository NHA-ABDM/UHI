package in.gov.abdm.uhi.EUABookingService.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long>{
	
	User findByHealthIdNumber(String abha_id);

    User findById(String abhaAddress);
}
