package in.gov.abdm.eua.userManagement.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.eua.userManagement.dto.dhp.ErrorResponseDTO;
import in.gov.abdm.eua.userManagement.dto.phr.RegistrationByMobileOrEmailRequest;
import in.gov.abdm.eua.userManagement.dto.phr.UserDTO;
import in.gov.abdm.eua.userManagement.service.impl.UserServiceImpl;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.BodyInserters;
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
    public ResponseEntity<RegistrationByMobileOrEmailRequest> saveUser(@RequestBody String userDetails) {
        try {
            RegistrationByMobileOrEmailRequest userDTO = objectMapper.readValue(userDetails, RegistrationByMobileOrEmailRequest.class);
            userService.saveUser(userDTO);

        } catch (Exception e) {

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(getErrorSchemaReady("Error Saving userData", "500"));
        }
        return ResponseEntity.status(HttpStatus.OK).body(getErrorSchemaReady("Success", "200"));
    }

    @PostMapping("/saveUsers")
    public void saveUsers(@RequestBody String userDetails) {
        try {
            RegistrationByMobileOrEmailRequest userDTO = objectMapper.readValue(userDetails, RegistrationByMobileOrEmailRequest.class);
            for(int i=0; i< 250; i++) {
                userDTO.getName().setFirst(RandomStringUtils.random(8, true, true));
                userDTO.setId(RandomStringUtils.random(5, true, true) +"@abdm");
                userDTO.setFullName(RandomStringUtils.random(15, true, false));
                userDTO.setEmail(RandomStringUtils.random(15, true, true)+"@email");
                this.webClient.post().uri("http://121.242.73.125:8902/api/v1/user/saveUser")
                        .body(BodyInserters.fromValue(userDTO))
                        .retrieve()
                        .bodyToMono(RegistrationByMobileOrEmailRequest.class)
                        .subscribe();
            }

        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
    }

        @GetMapping("/getUser/{abhaAddress}")
    public ResponseEntity<RegistrationByMobileOrEmailRequest> getUser(@PathVariable(name = "abhaAddress") String abhaAddress) {

        RegistrationByMobileOrEmailRequest userDetails;
        try {
            userDetails = userService.getUserByAbhaAddress(abhaAddress);

        } catch (Exception e) {

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(getErrorSchemaReady("Error getting userData", "500"));
        }
       return ResponseEntity.status(HttpStatus.OK).body(userDetails);
    }

    private RegistrationByMobileOrEmailRequest getErrorSchemaReady(String message, String code) {
        RegistrationByMobileOrEmailRequest byMobileOrEmailRequest = new RegistrationByMobileOrEmailRequest();
        ErrorResponseDTO errorResponseDTO = new ErrorResponseDTO();
        errorResponseDTO.setMessage(message);
        errorResponseDTO.setCode(code);
        errorResponseDTO.setPath("UserService.userController");
        byMobileOrEmailRequest.setResponse(errorResponseDTO);
        return byMobileOrEmailRequest;
    }
}
