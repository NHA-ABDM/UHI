package in.gov.abdm.uhi.registry.repository;

import javax.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.registry.entity.ParticipantKey;
@Repository
@Transactional
public interface ParticipantKeyRepository extends JpaRepository<ParticipantKey, Integer> {
    public ParticipantKey findByUniqueKeyId(String keyId);

}
