package in.gov.abdm.uhi.EUABookingService.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.UserRefreshToken;

@Repository
public interface UserRefreshTokenRepository extends JpaRepository<UserRefreshToken, Long> {

    UserRefreshToken getByUserHealthIdNumber(String healthIdNo);
}
