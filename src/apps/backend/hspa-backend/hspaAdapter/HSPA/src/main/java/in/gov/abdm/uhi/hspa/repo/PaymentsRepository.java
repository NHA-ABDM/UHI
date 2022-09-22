package in.gov.abdm.uhi.hspa.repo;


import in.gov.abdm.uhi.hspa.models.PaymentsModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentsRepository extends JpaRepository<PaymentsModel, Long>{
	List<PaymentsModel> findByTransactionId(String transactionId);

}
