package in.gov.abdm.uhi.registry.repository;

import java.util.List;

import javax.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.registry.entity.NetworkRole;
@Repository
@Transactional
public interface NetworkRoleRepository extends JpaRepository<NetworkRole, Integer> {
	public List<NetworkRole> findBySubscriberid(String subscriberId);
	public NetworkRole findByOperatingregionId(Integer id);
	
}
