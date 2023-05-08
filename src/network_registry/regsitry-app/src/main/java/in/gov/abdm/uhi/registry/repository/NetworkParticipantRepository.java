package in.gov.abdm.uhi.registry.repository;

import javax.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.registry.entity.NetworkParticipant;
@Repository
@Transactional
public interface NetworkParticipantRepository extends JpaRepository<NetworkParticipant, Integer> {
	
	public NetworkParticipant findByParticipantId(String participantId);
}
