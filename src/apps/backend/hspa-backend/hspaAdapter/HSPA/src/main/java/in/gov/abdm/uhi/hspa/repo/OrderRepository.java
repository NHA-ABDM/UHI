package in.gov.abdm.uhi.hspa.repo;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import in.gov.abdm.uhi.hspa.models.OrdersModel;

@Repository
public interface OrderRepository extends JpaRepository<OrdersModel, Long>{
	
	List<OrdersModel> findByOrderId(String orderid);
	List<OrdersModel> findByAbhaId(String abhaid);
	List<OrdersModel> findByHealthcareProfessionalId(String hprid);
	List<OrdersModel> findByHealthcareProfessionalIdOrderByServiceFulfillmentStartTimeDesc(String hprid);
	List<OrdersModel> findByHealthcareProfessionalIdOrderByServiceFulfillmentStartTime(String hprid);
	List<OrdersModel> findByAbhaIdOrderByServiceFulfillmentStartTime(String abhaid);
	List<OrdersModel> findByAppointmentId(String appointmentid);

}
