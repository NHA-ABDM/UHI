package in.gov.abdm.uhi.hspa.repo;


import in.gov.abdm.uhi.hspa.models.OrdersModel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<OrdersModel, Long> {

    List<OrdersModel> findByOrderId(String orderid);

    List<OrdersModel> findByAbhaId(String abhaid);

    List<OrdersModel> findByHealthcareProfessionalId(String hprid);

    List<OrdersModel> findByHealthcareProfessionalIdOrderByServiceFulfillmentStartTimeDesc(String hprid);

    List<OrdersModel> findByHealthcareProfessionalIdOrderByServiceFulfillmentStartTime(String hprid);

    List<OrdersModel> findByAbhaIdOrderByServiceFulfillmentStartTime(String abhaid);

    List<OrdersModel> findByAppointmentId(String appointmentid);

    List<OrdersModel> findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(
            String hprid, String aType);

    List<OrdersModel> findByTransId(String transid);

    Page<OrdersModel> findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTime(String hprid, String aType, Pageable p);

    List<OrdersModel> findByHealthcareProfessionalIdAndServiceFulfillmentTypeOrderByServiceFulfillmentStartTimeDesc(String hprid, String aType);
}
