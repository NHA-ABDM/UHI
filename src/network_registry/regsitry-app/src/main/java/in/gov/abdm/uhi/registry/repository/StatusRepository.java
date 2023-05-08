package in.gov.abdm.uhi.registry.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import in.gov.abdm.uhi.registry.entity.Status;

public interface StatusRepository extends JpaRepository<Status, Integer> {
 public Status findByNameIgnoreCase(String status);
	
}
