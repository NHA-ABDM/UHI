package in.gov.abdm.uhi.registry.service;

import java.util.List;

import in.gov.abdm.uhi.registry.dto.NetworkRoleDto;
import in.gov.abdm.uhi.registry.dto.SubscriberDto;
import in.gov.abdm.uhi.registry.entity.NetworkRole;

public interface NetworkRoleService {
public NetworkRole saveNetworkRole(NetworkRoleDto NetworkRoleDto);
	public NetworkRole updateNetworkRole(NetworkRole NetworkRole);
	public void deleteNetworkRole(Integer id);
	public List<NetworkRole> findAllNetworkRole();
	public NetworkRole getOneNetworkRole(Integer id);
	public List<SubscriberDto> isSubscriberIdExists(String subscriberId);
}
