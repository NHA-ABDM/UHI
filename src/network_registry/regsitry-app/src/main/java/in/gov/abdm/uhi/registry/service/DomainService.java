package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.entity.Domains;

public interface DomainService {
public List<Domains> findAllDomain();
public List<Domains> saveAllDomain(List<Domains> domains);
}
