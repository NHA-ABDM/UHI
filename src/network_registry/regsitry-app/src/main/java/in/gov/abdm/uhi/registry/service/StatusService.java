package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.entity.Status;

public interface StatusService {
 public List<Status> findAllStatus();
 public List<Status> saveStatusList(List<Status> statusList);
}
