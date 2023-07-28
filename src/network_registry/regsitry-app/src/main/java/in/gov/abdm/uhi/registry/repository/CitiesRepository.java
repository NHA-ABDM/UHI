package in.gov.abdm.uhi.registry.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import in.gov.abdm.uhi.registry.entity.Cities;

public interface CitiesRepository extends JpaRepository<Cities, Integer> {
	public Cities findBySdcaNameIgnoreCaseAndStdCode(String cityName, String stdcode);

	public Cities findByStdCode(String stdcode);

	public List<Cities> findByStateNameIgnoreCase(String name);
}
