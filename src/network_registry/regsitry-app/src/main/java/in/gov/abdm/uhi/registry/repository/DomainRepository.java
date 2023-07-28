package in.gov.abdm.uhi.registry.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import in.gov.abdm.uhi.registry.entity.Domains;

public interface DomainRepository extends JpaRepository<Domains, Integer> {
 public Domains findByNameIgnoreCase(String name);
}
