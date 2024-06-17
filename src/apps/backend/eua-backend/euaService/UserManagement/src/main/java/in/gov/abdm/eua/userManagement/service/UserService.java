package in.gov.abdm.eua.userManagement.service;

import in.gov.abdm.eua.userManagement.dto.phr.RegistrationByMobileOrEmailRequestDTO;
import in.gov.abdm.eua.userManagement.model.User;
import in.gov.abdm.eua.userManagement.service.impl.UserServiceImpl;
import org.modelmapper.ModelMapper;
import org.modelmapper.TypeMap;
import org.modelmapper.convention.MatchingStrategies;

public interface UserService {
    void saveUser(RegistrationByMobileOrEmailRequestDTO userDTO);

    RegistrationByMobileOrEmailRequestDTO getUserByAbhaAddress(String abhaAddress);

    default User getUserModelFromUserDTO(RegistrationByMobileOrEmailRequestDTO userData) {
        UserServiceImpl.LOGGER.info("Mapping user data from /registration/hid/confirm-init HidResponse to userDto");

        User userDTO;
        ModelMapper modelMapper = new ModelMapper();
        modelMapper.getConfiguration().setAmbiguityIgnored(true);
        TypeMap<RegistrationByMobileOrEmailRequestDTO, User> typeMapIfNotAlreadyPresent = modelMapper.createTypeMap(RegistrationByMobileOrEmailRequestDTO.class, User.class);

        typeMapIfNotAlreadyPresent.addMapping(src -> src.getName().getFirst(), User::setFirstName);
        typeMapIfNotAlreadyPresent.addMapping(src -> src.getName().getMiddle(), User::setMiddleName);
        typeMapIfNotAlreadyPresent.addMapping(src -> src.getName().getLast(), User::setLastName);

        typeMapIfNotAlreadyPresent.addMapping(src -> src.getDateOfBirth().getDateOfBirth(), User::setDateOfBirth);
        typeMapIfNotAlreadyPresent.addMapping(src -> src.getDateOfBirth().getMonthOfBirth(), User::setMonthOfBirth);
        typeMapIfNotAlreadyPresent.addMapping(src -> src.getDateOfBirth().getYearOfBirth(), User::setYearOfBirth);

        typeMapIfNotAlreadyPresent.addMapping(RegistrationByMobileOrEmailRequestDTO::getId, User::setId);


        userDTO = modelMapper.map(userData, User.class);

        modelMapper = null;

        UserServiceImpl.LOGGER.info("Mapped userDto is " + userDTO);

        return userDTO;

    }

    default RegistrationByMobileOrEmailRequestDTO getUserDtoFromUserModel(User userData) {
        UserServiceImpl.LOGGER.info("Mapping user data from /registration/hid/confirm-init HidResponse to userDto");

        RegistrationByMobileOrEmailRequestDTO userDTO;
        ModelMapper modelMapper = new ModelMapper();
        modelMapper.getConfiguration().setAmbiguityIgnored(true);
        modelMapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STANDARD);


        userDTO = modelMapper.map(userData, RegistrationByMobileOrEmailRequestDTO.class);

        userDTO.getDateOfBirth().setMonthOfBirth(userData.getMonthOfBirth());
        userDTO.getDateOfBirth().setYearOfBirth(userData.getYearOfBirth());

        UserServiceImpl.LOGGER.info("Mapped userDto is " + userDTO);

        modelMapper = null;

        return userDTO;

    }
}
