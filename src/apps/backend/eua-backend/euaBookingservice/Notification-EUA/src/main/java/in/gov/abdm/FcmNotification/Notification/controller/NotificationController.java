package in.gov.abdm.FcmNotification.Notification.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import in.gov.abdm.FcmNotification.Notification.dto.CancelOrderDTO;
import in.gov.abdm.FcmNotification.Notification.dto.ErrorResponseDTO;
import in.gov.abdm.FcmNotification.Notification.dto.ServiceResponseDTO;
import in.gov.abdm.FcmNotification.Notification.service.NotificationService;
import in.gov.abdm.uhi.common.dto.Request;
import reactor.core.publisher.Mono;

@RestController
public class NotificationController {
	Logger logger = LogManager.getLogger(NotificationController.class);
    final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping("/sendNotification")
    public ResponseEntity<Mono<ServiceResponseDTO>> sendNotification(@RequestBody Request request) {
        try {
        	logger.info("inside sendNotification  "+request);
            notificationService.sendNotificationToReceiver(request);
            logger.info("process Completed   "+DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));
        	
            
        }
        catch (InterruptedException e) {        	
        	logger.error("send notification exception  "+e.getStackTrace()+e);
        	Thread.currentThread().interrupt();
            ServiceResponseDTO responseDTO = new ServiceResponseDTO();
            ErrorResponseDTO errorResponseDTO = new ErrorResponseDTO();
            errorResponseDTO.setErrorString(e.getMessage());
            errorResponseDTO.setCode("500");
            errorResponseDTO.setPath("NotificationController");
            responseDTO.setError(errorResponseDTO);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(responseDTO));
        }
        catch (Exception e) {
        	logger.error("send notification exception  "+e.getStackTrace()+e);
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
        	logger.info("inside sendCancelNotification  "+request);
            notificationService.sendCancelNotificationToReceiver(request);
            logger.info("process Completed   "+DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));
        	
            
        } 
        catch (InterruptedException e) {        	
        	logger.error("send notification exception  "+e.getStackTrace()+e);
        	Thread.currentThread().interrupt();
            ServiceResponseDTO responseDTO = new ServiceResponseDTO();
            ErrorResponseDTO errorResponseDTO = new ErrorResponseDTO();
            errorResponseDTO.setErrorString(e.getMessage());
            errorResponseDTO.setCode("500");
            errorResponseDTO.setPath("NotificationController");
            responseDTO.setError(errorResponseDTO);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Mono.just(responseDTO));
        }
        catch (Exception e) {
        	logger.error("send Cancel notification exception  "+e.getStackTrace()+e);
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
