package in.gov.abdm.uhi.registry.serviceImpl;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import in.gov.abdm.uhi.registry.dto.NetworkRoleDto;
import in.gov.abdm.uhi.registry.entity.Domains;
import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
import in.gov.abdm.uhi.registry.entity.NetworkRole;
import in.gov.abdm.uhi.registry.entity.Status;
import in.gov.abdm.uhi.registry.exception.RecordAlreadyExists;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.repository.DomainRepository;
import in.gov.abdm.uhi.registry.repository.NetworkParticipantRepository;
import in.gov.abdm.uhi.registry.repository.NetworkRoleRepository;
import in.gov.abdm.uhi.registry.repository.StatusRepository;
import in.gov.abdm.uhi.registry.service.NetworkRoleService;

@Service
public class NetworkRoleServiceImpl implements NetworkRoleService {
	private static final Logger logger = LogManager.getLogger(NetworkRoleServiceImpl.class);

	ModelMapper map = new ModelMapper();
	@Autowired
	private NetworkRoleRepository networkRoleRepository;
	@Autowired

	private NetworkParticipantRepository networkParticipantRepository;

	@Autowired
	private DomainRepository domainRepository;

	@Autowired
	private StatusRepository statusRepository;

	ModelMapper mapper = new ModelMapper();

	@Override
	public NetworkRole saveNetworkRole(NetworkRoleDto networkRoleDto) {
		NetworkRole networkRole = null;
		NetworkParticipant networkParticipantData = null;
		logger.info("NetworkRoleServiceImp::saveNetworkRole");
		try {
			networkParticipantData = networkParticipantRepository.findById(networkRoleDto.getNetworkParticipantId())
					.get();
		} catch (Exception e) {
			throw new ResourceNotFoundException("Participant id does not exists");
		}

		if (networkParticipantData != null) {
			List<NetworkRole> networkroleListData = networkParticipantData.getNetworkrole();
			Domains extractDomins = extractDomins(networkRoleDto.getDomain());
			networkRole = mapper.map(networkRoleDto, NetworkRole.class);
			if (isDomainExists(networkroleListData,extractDomins,networkRoleDto.getType())) {
				throw new RecordAlreadyExists("Domain already eists");
			}

			
			String generateSubscriberId = generateSubscriberId(networkParticipantData, networkRoleDto.getType(),
					networkRoleDto.getDomain());
			networkRole.setDomain(extractDomins);
			networkRole.setSubscriberid(generateSubscriberId);
			networkRole.setStatus(extractStatus(networkRoleDto.getStatus()));
			networkroleListData.add(networkRole);
			networkParticipantData.setNetworkrole(networkroleListData);
			try {
				networkParticipantRepository.save(networkParticipantData);
			} catch (DataIntegrityViolationException e) {
				throw new RecordAlreadyExists("Subscriber id already exist!");
			}
			return networkRole;
		} else {
			throw new ResourceNotFoundException("Participant id does not exists");
		}

	}

	private boolean isDomainExists(List<NetworkRole> networkroleListData, Domains domain,String type) {
			List<NetworkRole> foundData = networkroleListData.stream()
					.filter(r -> r.getDomain().equals(domain) && r.getType().equalsIgnoreCase(type))
					.collect(Collectors.toList());
			if (!foundData.isEmpty()) {
				return true;
			}
		return false;
	}

	@Override
	public NetworkRole updateNetworkRole(NetworkRole networkRole) {
		logger.info("NetworkRoleServiceImp::updateNetworkRole()");
		NetworkRole networkRoleData = this.getOneNetworkRole(networkRole.getId());
		// NetworkRole oneNetworkRole = this.getOneNetworkRole(networkRole.getId());
		List<NetworkRole> findBySubscriberid = networkRoleRepository.findBySubscriberid(networkRole.getSubscriberid());

		if (networkRoleData != null) {
			Domains extractDomins = extractDomins(networkRole.getDomain().getName());
			networkRoleData.setSubscriberid(networkRole.getSubscriberid());
			if (!networkRoleData.getDomain().equals(extractDomins)) {
				List<NetworkRole> collectesData = findBySubscriberid.stream()
						.filter(d -> d.getDomain().equals(extractDomins)).collect(Collectors.toList());
				if (collectesData.isEmpty()) {
					networkRoleData.setDomain(extractDomins);
				} else {
					throw new RecordAlreadyExists("Domain already exist!");
				}
			}
			networkRoleData.setStatus(extractStatus(networkRole.getStatus().getName()));
			networkRoleData.setType(networkRole.getType());
			networkRoleData.setSubscriberurl(networkRole.getSubscriberurl());
			networkRoleRepository.save(networkRoleData);
			return networkRoleData;
		} else {
			throw new ResourceNotFoundException("Participant id does not exists");
		}

	}

	@Override
	public void deleteNetworkRole(Integer id) {
		logger.info("NetworkRoleServiceImp::deleteNetworkRole()");

		NetworkRole networkRoleData = this.getOneNetworkRole(id);
		if (networkRoleData != null)
			networkRoleRepository.deleteById(id);
		else {
			throw new ResourceNotFoundException("Network role id does not exists");
		}
	}

	@Override
	public List<NetworkRole> findAllNetworkRole() {
		logger.info("NetworkRoleServiceImp::findAllNetworkRole()");
		List<NetworkRole> networkRoleDataList = networkRoleRepository.findAll();
		if (networkRoleDataList.isEmpty()) {
			throw new ResourceNotFoundException("No record found!");
		}
		return networkRoleDataList;
	}

	@Override
	public NetworkRole getOneNetworkRole(Integer id) {
		logger.info("NetworkRoleServiceImp::getOneNetworkRole()");
		try {
			logger.error("NetworkRoleServiceImp::getOneNetworkRole()");

			return networkRoleRepository.findById(id).get();
		} catch (NoSuchElementException e) {
			throw new ResourceNotFoundException("Network role id does not exists!");
		}

	}

	public Domains extractDomins(String domain) {
		logger.info("NetworkRoleServiceImp::extractDomins()");
		Domains domains = domainRepository.findByNameIgnoreCase(domain);
		if (domains == null) {
			throw new ResourceNotFoundException("Domain name not found");
		}
		return domains;
	}

	public Status extractStatus(String status) {
		logger.info("NetworkRoleServiceImp::extractStatus()");
		Status statusData = statusRepository.findByNameIgnoreCase(status);
		if (statusData == null) {
			throw new ResourceNotFoundException("Status not found");
		}
		return statusData;

	}

	public String generateSubscriberId(NetworkParticipant networkParticipant, String type, String domain) {
		logger.info("NetworkRoleServiceImp::extractStatus()");
		String subscriberId = networkParticipant.getParticipantId() + "." + type.toLowerCase();
		return subscriberId;

	}

}
