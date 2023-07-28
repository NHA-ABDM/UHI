package in.gov.abdm.uhi.registry.serviceImpl;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import in.gov.abdm.uhi.registry.dto.OperatingRegionDto;
import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.OperatingRegion;
import in.gov.abdm.uhi.registry.exception.RecordAlreadyExists;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.repository.CitiesRepository;
import in.gov.abdm.uhi.registry.repository.NetworkRoleRepository;
import in.gov.abdm.uhi.registry.repository.OperatingRegionRepository;
import in.gov.abdm.uhi.registry.service.OperatingRegionService;

@Service
public class OperatingRegionServiceImpl implements OperatingRegionService {
	private static final Logger logger = LogManager.getLogger(NetworkRoleServiceImpl.class);

	@Autowired
	private OperatingRegionRepository operatingRegionRepository;
	@Autowired
	private NetworkRoleRepository networkRoleRepository;
	@Autowired
	private CitiesRepository citiesRepository;

	@Override
	public OperatingRegion saveOperatingRegion(OperatingRegionDto operatingRegionDto) {
		ModelMapper mapper = new ModelMapper();
		String cityData = operatingRegionDto.getCity();
		String stdcode = cityData.substring(cityData.indexOf("-") + 1, cityData.length());
		String cityName = cityData.substring(0, cityData.indexOf("-"));
		logger.info("OperatingRegionServiceImpl::saveOperatingRegion()");
		NetworkRole networkRole = networkRoleRepository.findById(operatingRegionDto.getNetworkRoleId()).get();
		if (networkRole != null) {
			List<OperatingRegion> regionSet = networkRole.getOperatingregion();
			OperatingRegion operatingRegion = mapper.map(operatingRegionDto, OperatingRegion.class);
			Cities extractCities = extractCities(cityName, stdcode);
			operatingRegion.setCity(extractCities);
			isCityExist(regionSet, extractCities);
			regionSet.add(operatingRegion);
			networkRole.setOperatingregion(regionSet);
			networkRoleRepository.save(networkRole);
			return operatingRegion;
		} else {
			throw new ResourceNotFoundException("Network role id does not exists!");
		}
	}

	private void isCityExist(List<OperatingRegion> regionSet, Cities extractCities) {
		for (OperatingRegion rr : regionSet) {
			if (rr.getCity().equals(extractCities)) {
				throw new RecordAlreadyExists("City already exist");
			}
		}
	}

	@Override
	public OperatingRegion updateOperatingRegion(OperatingRegion operatingRegion) {
		NetworkRole userOperatingRegionData = networkRoleRepository.findByOperatingregionId(operatingRegion.getId());
		if (userOperatingRegionData == null) {
			throw new ResourceNotFoundException("User id does not exist!");
		}
		List<OperatingRegion> operatingregionList = userOperatingRegionData.getOperatingregion();

		String cityData = operatingRegion.getCity().getSdcaName();
		String stdCode = cityData.substring(cityData.indexOf("-") + 1, cityData.length());
		String cityName = cityData.substring(0, cityData.indexOf("-"));
		logger.info("OperatingRegionServiceImpl::updateOperatingRegion()");
		OperatingRegion operatingRegionData = this.getOneOperatingRegion(operatingRegion.getId());
		Cities citiesData = extractCities(cityName, stdCode);
		List<OperatingRegion> collectedCity = operatingregionList.stream().filter(x -> x.getCity().equals(citiesData))
				.collect(Collectors.toList());
		if (!collectedCity.isEmpty()) {
			throw new RecordAlreadyExists("City already exist");
		}
		operatingRegionData.setCity(citiesData);
		operatingRegionData.setCountry(operatingRegion.getCountry());
		return operatingRegionRepository.save(operatingRegionData);
	}

	@Override
	public List<OperatingRegion> findAllOperatingRegion() {
		logger.info("OperatingRegionServiceImpl::findAllOperatingRegion()");

		List<OperatingRegion> operatingRegionData = operatingRegionRepository.findAll();
		return operatingRegionData;
	}

	@Override
	public OperatingRegion getOneOperatingRegion(Integer id) {
		logger.info("OperatingRegionServiceImpl::getOneOperatingRegion()");

		try {
			return operatingRegionRepository.findById(id).get();
		} catch (NoSuchElementException e) {
			throw new ResourceNotFoundException("Operating region id does not exists!");
		}
	}

	@Override
	public void deleteOperatingRegion(Integer id) {
		logger.info("OperatingRegionServiceImpl::deleteOperatingRegion()");
		this.getOneOperatingRegion(id);
		operatingRegionRepository.deleteById(id);
	}

	public Cities extractCities(String city, String stdcode) {
		Cities cityData = citiesRepository.findBySdcaNameIgnoreCaseAndStdCode(city, stdcode);
		if (cityData == null) {
			throw new ResourceNotFoundException(city + " not found");
		}
		return cityData;
	}

}
