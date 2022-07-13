package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.UserAbhaAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserAbhaAddressRepository extends JpaRepository<UserAbhaAddress, Long> {

    List<UserAbhaAddress> findByPhrAddress(String address);
}
