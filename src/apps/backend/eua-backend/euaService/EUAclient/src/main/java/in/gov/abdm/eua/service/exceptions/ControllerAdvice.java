package in.gov.abdm.eua.service.exceptions;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.common.dto.Error;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.cloud.client.circuitbreaker.NoFallbackAvailableException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.InvalidKeySpecException;

@RestControllerAdvice
public class ControllerAdvice {
    private static final Logger LOGGER = LogManager.getLogger(ControllerAdvice.class);

    @ExceptionHandler(Exception.class)
    // @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ResponseEntity<Response> serverExceptionHandler(Exception ex) {

        LOGGER.error("ControllerAdvice called::{}", ex.getMessage());
       if (ex.getClass() == JsonParseException.class) {
            return handleInvalidRequestException(ex);
        } else if (ex.getClass() == LookupException.class || ex.getClass() == NoFallbackAvailableException.class) {
            return handleLookupException();
        } else if (ex.getClass() == IOException.class || ex.getClass() == NoSuchAlgorithmException.class ||
                ex.getClass() == InvalidKeySpecException.class || ex.getClass() == NoSuchProviderException.class) {
            return handleLookupException();
        } else if(ex.getClass() == JsonProcessingException.class) {
            return handleJsonProcessorException();
        }
        else{
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    null);
        }
    }
    @ExceptionHandler(JsonProcessingException.class)
    public ResponseEntity<Response> handleJsonProcessorException(Exception ex) {
        return handleJsonProcessorException();
    }

    @ExceptionHandler(ParticipantValidationError.class)
    public ResponseEntity<Response> handleParticipantValidationError(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
               Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(EuaError.PARTICIPANT_VALIDATION_FAILURE.getMessage()).code(EuaError.PARTICIPANT_VALIDATION_FAILURE.getCode()).build()).build());
    }

    @ExceptionHandler(EuaException.class)
    public ResponseEntity<Response> handleInternalServerError(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(EuaError.INTERNAL_SERVER_ERROR.getMessage()).code(EuaError.INTERNAL_SERVER_ERROR.getCode()).build()).build());
    }

    @ExceptionHandler(AuthHeaderNotFoundError.class)
    public ResponseEntity<Response> handleAuthHeaderNotFoundError(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(EuaError.AUTH_HEADER_NOT_FOUND.getMessage()).code(EuaError.AUTH_HEADER_NOT_FOUND.getCode()).build()).build());
    }

    @ExceptionHandler(HeaderVerificationFailedError.class)
    public ResponseEntity<Response> handleHeaderVerificationFailedError(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(EuaError.HEADER_VERFICATION_FAILED.getMessage()).code(EuaError.HEADER_VERFICATION_FAILED.getCode()).build()).build());
    }

    @ExceptionHandler(LookupException.class)
    public ResponseEntity<Response> handleLookupError(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
               Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(EuaError.LOOKUP_FAILED.getMessage()).code(EuaError.LOOKUP_FAILED.getCode()).build()).build());
    }

    @ExceptionHandler(InvalidKeyError.class)
    public ResponseEntity<Response> handleInvalidKeyError(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
               Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(EuaError.INVALID_KEY.getMessage()).code(EuaError.INVALID_KEY.getCode()).build()).build());
    }

    private ResponseEntity<Response> handleInvalidRequestException(Exception ex) {

        Error err = new Error(String.valueOf(EuaError.INVALID_REQUEST.getCode()), ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
               Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
    }

    private ResponseEntity<Response> handleLookupException() {
        LOGGER.error("Lookup call failed ::");
        Error err = new Error(String.valueOf(EuaError.INTERNAL_SERVER_ERROR.getCode()), EuaError.INTERNAL_SERVER_ERROR.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
    }

    private ResponseEntity<Response> handleJsonProcessorException() {
        LOGGER.error("Invalid JSON failed ::");
        Error err = new Error(String.valueOf(EuaError.INVALID_JSON_ERROR.getCode()), EuaError.INVALID_JSON_ERROR.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
    }
}
