package in.gov.abdm.uhi.registry.service;


import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.web.bind.annotation.RequestHeader;

import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.SearchDto;
import in.gov.abdm.uhi.registry.entity.NetworkParticipant;

public interface NetworkParticipantService {
	public NetworkParticipant saveNetworkParticipant(NetworkParticipant networkParticipant);

	public List<NetworkParticipant> findAllNetworkParticipant();

	public NetworkParticipant getOneNetworkParticipant(Integer id);

	public void deleteNetworkParticipant(Integer id);
	public NetworkParticipant updateNetworkParticipant(NetworkParticipant networkParticipant);
	public Object lookup(LookupDto subscriber);
	public Object search(String stringSearchDto, @RequestHeader Map<String, String> headers, boolean isInternal) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException, SignatureException, InvalidKeyException;
	public Object GatewaySearch(SearchDto searchDto);

}
