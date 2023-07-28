package in.gov.abdm.uhi.registry.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import in.gov.abdm.uhi.registry.entity.Status;
import in.gov.abdm.uhi.registry.repository.StatusRepository;
import in.gov.abdm.uhi.registry.service.StatusService;
@Service
public class StatusServiceImpl implements StatusService {
@Autowired
private StatusRepository statusRepository;
	@Override
	public List<Status> findAllStatus() {
		return statusRepository.findAll();
	}
	@Override
	public List<Status> saveStatusList(List<Status> statusList) {
		return statusRepository.saveAll(statusList);
	}

}
