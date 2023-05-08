package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.dto.NetworkRoleDto;
import in.gov.abdm.uhi.registry.entity.NetworkRole;

public interface NetworkRoleService {
public NetworkRole saveNetworkRole(NetworkRoleDto NetworkRoleDto);
	public NetworkRole updateNetworkRole(NetworkRole NetworkRole);

	
	public void deleteNetworkRole(Integer id);

	//public String lookup(LookupDto subscriber);
	public List<NetworkRole> findAllNetworkRole();
	public NetworkRole getOneNetworkRole(Integer id);
}
