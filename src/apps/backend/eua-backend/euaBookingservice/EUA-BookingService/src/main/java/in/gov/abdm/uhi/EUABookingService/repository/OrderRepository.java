package in.gov.abdm.uhi.EUABookingService.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.Orders;

@Repository
public interface OrderRepository extends JpaRepository<Orders, Long>{
	
	List<Orders> findByOrderId(String orderid);
	List<Orders> findByAbhaId(String abhaid);
	List<Orders> findByAbhaIdOrderByServiceFulfillmentStartTime(String abhaid);
	List<Orders> findByAbhaIdOrderByServiceFulfillmentStartTimeDesc(String abhaid);
	List<Orders> findByAbhaIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(String abhaid, String aType);
	List<Orders> findByAbhaIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTimeDesc(String hprid,
			String aType);

}
