package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.dto.StateDto;
import in.gov.abdm.uhi.registry.entity.State;


public interface StateService {
public List<StateDto> findAllState();
public List<State> saveAllState(List<State>stateList);
//public List<CitiesDto> findByStateName(String name);
}
