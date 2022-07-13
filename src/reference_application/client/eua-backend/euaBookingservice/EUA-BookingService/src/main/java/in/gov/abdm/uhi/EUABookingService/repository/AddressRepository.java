package in.gov.abdm.uhi.EUABookingService.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.Address;


@Repository
public interface AddressRepository extends JpaRepository<Address, Long>{

}
