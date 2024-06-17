package in.gov.abdm.FcmNotification.Notification.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.FcmNotification.Notification.dto.CancelOrderDTO;
import in.gov.abdm.FcmNotification.Notification.dto.ErrorResponseDTO;
import in.gov.abdm.FcmNotification.Notification.dto.ServiceResponseDTO;
import in.gov.abdm.FcmNotification.Notification.service.NotificationService;
import in.gov.abdm.uhi.common.dto.Request;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
public class NotificationController {

    final NotificationService notificationService;
    Logger LOGGER = LoggerFactory.getLogger(NotificationController.class);

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping("/sendNotification")
    public ResponseEntity<Mono<ServiceResponseDTO>> sendNotification(@RequestBody Request request) {
        try {
            notificationService.sendNotificationToReceiver(request);
        } catch (Exception e) {
            ServiceResponseDTO responseDTO = new ServiceResponseDTO();
            ErrorResponseDTO errorResponseDTO = new ErrorResponseDTO();
            errorResponseDTO.setErrorString(e.getMessage());
            errorResponseDTO.setCode("500");
            errorResponseDTO.setPath("NotificationController");
            responseDTO.setError(errorResponseDTO);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(responseDTO));
        }
        ServiceResponseDTO responseDTO = new ServiceResponseDTO();
        responseDTO.setResponse("Notification Sent");
        return ResponseEntity.status(HttpStatus.OK).body(Mono.just(responseDTO));

    }

    @PostMapping("/sendCancelNotification")
    public ResponseEntity<Mono<ServiceResponseDTO>> sendCancelNotification(@RequestBody CancelOrderDTO request) {
        try {
            LOGGER.info("inside sendCancelNotification  " + request);
            ObjectMapper objectMapper = new ObjectMapper();
            LOGGER.info("request in string  " + objectMapper.writeValueAsString(request));
            notificationService.sendCancelNotificationToReceiver(request);
            LOGGER.info("process Completed   " + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));


        } catch (Exception e) {
            LOGGER.error("send Cancel notification exception  " + e.getStackTrace());
            ServiceResponseDTO responseDTO = new ServiceResponseDTO();
            ErrorResponseDTO errorResponseDTO = new ErrorResponseDTO();
            errorResponseDTO.setErrorString(e.getMessage());
            errorResponseDTO.setCode("500");
            errorResponseDTO.setPath("EUA-Cancel-NotificationController");
            responseDTO.setError(errorResponseDTO);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(responseDTO));
        }
        ServiceResponseDTO responseDTO = new ServiceResponseDTO();
        responseDTO.setResponse("Notification Sent");
        return ResponseEntity.status(HttpStatus.OK).body(Mono.just(responseDTO));

    }


}
