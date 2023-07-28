package in.gov.abdm.uhi.registry.serviceImpl;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import in.gov.abdm.uhi.registry.entity.Domains;
import in.gov.abdm.uhi.registry.repository.DomainRepository;
import in.gov.abdm.uhi.registry.service.DomainService;

@Service
public class DomainServiceImpl implements DomainService {
	private static final Logger logger = LogManager.getLogger(CityServiceImpl.class);
	@Autowired
	private DomainRepository domainRepository;

	@Override
	public List<Domains> findAllDomain() {
		logger.info("DomainServiceImpl::findAllDomain()");
		logger.debug("DomainServiceImpl::findAllDomain()");
		return domainRepository.findAll();
	}

	@Override
	public List<Domains> saveAllDomain(List<Domains> domains) {
		logger.info("DomainServiceImpl::saveAllDomain()");
		logger.debug("DomainServiceImpl::saveAllDomain()");
		return domainRepository.saveAll(domains);
	}

}
