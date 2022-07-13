package in.gov.abdm.uhi.EUABookingService.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.Payments;

@Repository
public interface PaymentsRepository extends JpaRepository<Payments, Long>{
	List<Payments> findByTransactionId(String transactionId);

}
