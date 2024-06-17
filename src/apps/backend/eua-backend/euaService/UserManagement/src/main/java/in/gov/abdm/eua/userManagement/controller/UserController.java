package in.gov.abdm.eua.userManagement.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.userManagement.dto.dhp.ErrorResponseDTO;
import in.gov.abdm.eua.userManagement.dto.phr.RegistrationByMobileOrEmailRequestDTO;
import in.gov.abdm.eua.userManagement.service.impl.UserServiceImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;

@Tag(name = "Login and Registration using HealthId number", description = "These APIs are intended to be used for user registration and login to EUA using ABHA number and PHR address. These APIs are using PHR's APIs internally")
@RestController
@RequestMapping("api/v1/user")
public class UserController {
    final
    ObjectMapper objectMapper;

    final
    UserServiceImpl userService;

    final
    WebClient webClient;


    public UserController(ObjectMapper objectMapper, UserServiceImpl userService, WebClient webClient) {
        this.objectMapper = objectMapper;
        this.userService = userService;
        this.webClient = webClient;
    }

    @PostMapping("/saveUser")
    public ResponseEntity<RegistrationByMobileOrEmailRequestDTO> saveUser(@RequestBody String userDetails) {
        try {
            RegistrationByMobileOrEmailRequestDTO userDTO = objectMapper.readValue(userDetails, RegistrationByMobileOrEmailRequestDTO.class);
            userService.saveUser(userDTO);

        } catch (Exception e) {

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(getErrorSchemaReady("Error Saving userData", "500"));
        }
        return ResponseEntity.status(HttpStatus.OK).body(getErrorSchemaReady("Success", "200"));
    }


    @GetMapping("/getUser/{abhaAddress}")
    public ResponseEntity<RegistrationByMobileOrEmailRequestDTO> getUser(@PathVariable(name = "abhaAddress") String abhaAddress) {

        RegistrationByMobileOrEmailRequestDTO userDetails;
        try {
            userDetails = userService.getUserByAbhaAddress(abhaAddress);

        } catch (Exception e) {

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(getErrorSchemaReady("Error getting userData", "500"));
        }
        return ResponseEntity.status(HttpStatus.OK).body(userDetails);
    }

    private RegistrationByMobileOrEmailRequestDTO getErrorSchemaReady(String message, String code) {
        RegistrationByMobileOrEmailRequestDTO byMobileOrEmailRequest = new RegistrationByMobileOrEmailRequestDTO();
        ErrorResponseDTO errorResponseDTO = new ErrorResponseDTO();
        errorResponseDTO.setMessage(message);
        errorResponseDTO.setCode(code);
        errorResponseDTO.setPath("UserService.userController");
        byMobileOrEmailRequest.setResponse(errorResponseDTO);
        return byMobileOrEmailRequest;
    }
}
