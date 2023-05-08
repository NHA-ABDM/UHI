package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.dto.OperatingRegionDto;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;

public interface OperatingRegionService {
	public OperatingRegion saveOperatingRegion(OperatingRegionDto OperatingRegionDto);

	public List<OperatingRegion> findAllOperatingRegion();

	public OperatingRegion getOneOperatingRegion(Integer id);

	public void deleteOperatingRegion(Integer id);

	public OperatingRegion updateOperatingRegion(OperatingRegion operatingRegion);
}
