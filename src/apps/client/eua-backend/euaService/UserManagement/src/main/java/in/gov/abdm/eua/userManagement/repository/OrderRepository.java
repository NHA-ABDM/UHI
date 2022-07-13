package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.Orders;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Orders, Long>{
	
	List<Orders> findByOrderId(String orderid);
	List<Orders> findByAbhaId(String abhaid);

}
