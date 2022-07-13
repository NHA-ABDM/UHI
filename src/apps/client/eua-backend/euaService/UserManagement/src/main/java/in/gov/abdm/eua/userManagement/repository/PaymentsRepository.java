package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.Payments;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentsRepository extends JpaRepository<Payments, Long>{
	List<Payments> findByTransactionId(String transactionId);

}
