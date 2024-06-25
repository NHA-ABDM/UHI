package in.gov.abdm.eua.userManagement.service.impl;

import in.gov.abdm.eua.userManagement.dto.phr.RegistrationByMobileOrEmailRequestDTO;
import in.gov.abdm.eua.userManagement.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements in.gov.abdm.eua.userManagement.service.UserService {
    public static final Logger LOGGER = LoggerFactory.getLogger(UserServiceImpl.class);


    private final UserRepository userRepo;

    public UserServiceImpl(UserRepository userRepo) {
        this.userRepo = userRepo;
    }


    @Override
    public void saveUser(RegistrationByMobileOrEmailRequestDTO userDTO) {
        userRepo.save(getUserModelFromUserDTO(userDTO));

    }

    @Override
    public RegistrationByMobileOrEmailRequestDTO getUserByAbhaAddress(String abhaAddress) {
        return getUserDtoFromUserModel(userRepo.findById(abhaAddress));
    }


}
