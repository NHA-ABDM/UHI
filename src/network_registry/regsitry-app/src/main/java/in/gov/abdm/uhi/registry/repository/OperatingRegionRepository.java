package in.gov.abdm.uhi.registry.repository;

import javax.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;
@Repository
@Transactional
public interface OperatingRegionRepository extends JpaRepository<OperatingRegion, Integer> {

	public OperatingRegion findByCityStdCodeAndCitySdcaName(String stdcode,String sdcaName);
}