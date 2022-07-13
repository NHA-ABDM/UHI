package in.gov.abdm.uhi.EUABookingService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.UserAbhaAddress;

@Repository
public interface UserAbhaAddressRepository extends JpaRepository<UserAbhaAddress, Long> {

    List<UserAbhaAddress> findByPhrAddress(String address);
}
