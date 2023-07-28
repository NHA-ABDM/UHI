package in.gov.abdm.uhi.registry.serviceImpl;

import java.util.List;
import java.util.stream.Collectors;

import javax.persistence.EntityManager;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import in.gov.abdm.uhi.registry.dto.CitiesDto;
import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.State;
import in.gov.abdm.uhi.registry.exception.RecordAlreadyExists;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.repository.CitiesRepository;
import in.gov.abdm.uhi.registry.repository.StateRepository;
import in.gov.abdm.uhi.registry.service.CityService;

@Service
public class CityServiceImpl implements CityService {
	private static final Logger logger = LogManager.getLogger(CityServiceImpl.class);
	@Autowired
	private CitiesRepository citiesRepository;
	@Autowired
	EntityManager entityManager;
	@Autowired
	StateRepository stateRepository;
	ModelMapper mapper = new ModelMapper();

	@Override
	public List<Cities> findAllCity() {
		return citiesRepository.findAll();
	}

	@Override
	public List<Cities> saveAllCity(List<Cities> cities) {
		List<State> allState = stateRepository.findAll();
		if (allState.isEmpty()) {
			throw new ResourceNotFoundException("State table is empty!");
		}
		cities.stream().forEach(x -> x.getState());
		;
		for (Cities ct : cities) {
			for (State st : allState) {
				if (st.getName().equalsIgnoreCase((ct.getState().getName()))) {
				/*	ct.getStdCode(); String stdCode = ct.getStdCode(); 
					stdCode ="std:0" + stdCode; 
					ct.setStdCode(stdCode);*/
					State state = entityManager.getReference(State.class, st.getId());
					ct.setState(state);
				}
			}
		}
		logger.info("CityServiceImpl::saveAllCity()");
		logger.debug("CityServiceImpl::saveAllCity()");
		try {
			return citiesRepository.saveAll(cities);
		} catch (DataIntegrityViolationException e) {
			throw new RecordAlreadyExists("City already exist!");
		} catch (Exception e) {
			throw new RecordAlreadyExists("State does not exist!");
		}

	}

	public boolean isAlreadyExists(List<Cities> cityData, Cities city) {
		List<Cities> cityListData = cityData.stream().filter(x -> x.equals(city)).collect(Collectors.toList());
		if (cityListData.isEmpty()) {
			return true;
		}
		return false;
	}

	@Override
	public List<CitiesDto> findByStateName(String name) {
		 List<Cities> cityList = citiesRepository.findByStateNameIgnoreCase(name);
		 List<CitiesDto> collectedData = cityList.stream().map(x->(mapper.map(x,CitiesDto.class))).collect(Collectors.toList());
		 return collectedData;
	}

}
