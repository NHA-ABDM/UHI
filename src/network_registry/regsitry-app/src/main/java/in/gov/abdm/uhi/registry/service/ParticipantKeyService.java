package in.gov.abdm.uhi.registry.service;

import java.security.NoSuchAlgorithmException;
import java.util.List;

import in.gov.abdm.uhi.registry.dto.ParticipantKeyDto;
import in.gov.abdm.uhi.registry.entity.ParticipantKey;

public interface ParticipantKeyService {
	public ParticipantKey saveParticipantKey(ParticipantKeyDto ParticipantKeyDto) throws NoSuchAlgorithmException;

	public List<ParticipantKey> findAllParticipantKey();

	public ParticipantKey getOneParticipantKey(Integer id);

	public void deleteParticipantKey(Integer id);
	
	public ParticipantKey updateParticipantKey(ParticipantKey NetworkRole);
}
