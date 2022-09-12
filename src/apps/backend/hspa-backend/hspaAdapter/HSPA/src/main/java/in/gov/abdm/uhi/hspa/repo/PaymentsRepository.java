package in.gov.abdm.uhi.hspa.repo;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.hspa.models.PaymentsModel;

@Repository
public interface PaymentsRepository extends JpaRepository<PaymentsModel, Long>{
	List<PaymentsModel> findByTransactionId(String transactionId);

}
