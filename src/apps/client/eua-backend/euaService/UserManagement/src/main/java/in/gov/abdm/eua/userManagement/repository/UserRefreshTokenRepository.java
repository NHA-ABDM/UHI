package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.UserRefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRefreshTokenRepository extends JpaRepository<UserRefreshToken, Long> {

    UserRefreshToken getByUserHealthIdNumber(String healthIdNo);
}
