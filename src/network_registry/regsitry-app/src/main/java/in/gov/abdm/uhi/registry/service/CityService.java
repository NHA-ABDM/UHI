package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.dto.CitiesDto;
import in.gov.abdm.uhi.registry.entity.Cities;

public interface CityService {
	public List<Cities> findAllCity();
	public List<Cities> saveAllCity(List<Cities> cities);
	public List<CitiesDto> findByStateName(String name);
}
