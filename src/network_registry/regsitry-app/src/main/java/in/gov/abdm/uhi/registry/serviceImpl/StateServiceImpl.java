package in.gov.abdm.uhi.registry.serviceImpl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.registry.dto.CitiesDto;
import in.gov.abdm.uhi.registry.dto.StateDto;
import in.gov.abdm.uhi.registry.entity.Cities;
import in.gov.abdm.uhi.registry.entity.State;
import in.gov.abdm.uhi.registry.exception.RecordAlreadyExists;
import in.gov.abdm.uhi.registry.repository.StateRepository;
import in.gov.abdm.uhi.registry.service.StateService;

@Service
public class StateServiceImpl implements StateService {
	@Autowired
	private StateRepository stateRepository;

	ModelMapper mapper = new ModelMapper();
	@Autowired
	ObjectMapper objMapper;

	@Override
	public List<StateDto> findAllState() {
		List<State> stateList = stateRepository.findAll();
		List<StateDto> stateValues = new ArrayList<StateDto>();
		for (State state : stateList) {
			StateDto map = mapper.map(state, StateDto.class);
			stateValues.add(map);
		}
		return stateValues;

	}

	@Override
	public List<State> saveAllState(List<State> stateList) {
		// List<List<Cities>> collect =
		// stateList.stream().map(x->x.getCities()).collect(Collectors.toList());

		// Cities cities=null;
		/*
		 * for (State s: stateList) { List<Cities> cityData = s.getCities(); for(Cities
		 * c:cityData) { c.getStdCode(); String stdCode = c.getStdCode(); stdCode =
		 * "std:0" + stdCode; c.setStdCode(stdCode); s.setCities(cityData); }
		 * //stateList.add(st); }
		 */
		try {
		return stateRepository.saveAll(stateList);
		}catch (Exception e) {
			throw new RecordAlreadyExists("State already exist!",e);
		}
	}

	
	

}
