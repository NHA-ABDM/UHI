package in.gov.abdm.eua.userManagement.service;

import in.gov.abdm.eua.userManagement.dto.phr.LoginPostVerificationRequest;
import in.gov.abdm.eua.userManagement.dto.phr.OtpRequestForXToken;
import in.gov.abdm.eua.userManagement.dto.phr.UserDTO;

import javax.validation.Valid;

public interface UserService {
    UserDTO getUserDTO();

    void setUserDTO(UserDTO userDTO);

    void getUserProfile(String auth, String xtoken, @Valid OtpRequestForXToken request);

    //    @Async TODO: Make this async
    void saveUserToDb(UserDTO userDTO);

    void saveUserRefreshToken(String refreshToken, @Valid LoginPostVerificationRequest otpDTO);
}
