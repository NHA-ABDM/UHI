package in.gov.abdm.uhi.registry.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import in.gov.abdm.uhi.registry.entity.State;


public interface StateRepository extends JpaRepository<State, Integer>{
public List<State> findByNameIgnoreCase(String name);
//public List<State> findByNameIgnoreCase(String name);
}
