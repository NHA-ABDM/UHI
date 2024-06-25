package in.gov.abdm.uhi.hspa.exceptions;

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
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;

@RestControllerAdvice
public class ControllerAdvice {
    private static final Logger LOGGER = LogManager.getLogger(ControllerAdvice.class);

    @ExceptionHandler(Exception.class)
    // @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ResponseEntity<Response> serverExceptionHandler(Exception ex) {

        LOGGER.error("ControllerAdvice called::{}", ex.getMessage());
        if (ex.getClass() == InvalidRequestException.class) {
            return handleInvalidRequestException(ex);
        } else if (ex.getClass() == JsonParseException.class) {
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
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());
        return handleJsonProcessorException();
    }

    @ExceptionHandler(ParticipantValidationError.class)
    public ResponseEntity<Response> handleParticipantValidationError(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
           Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.PARTICIPANT_VALIDATION_FAILURE.getMessage()).code(GatewayError.PARTICIPANT_VALIDATION_FAILURE.getCode()).build()).build());
    }

    //(JsonProcessingException | NoSuchAlgorithmException | NoSuchProviderException |
    //                         InvalidKeyException | SignatureException | InvalidKeySpecException e)

    @ExceptionHandler(NoSuchAlgorithmException.class)
    public ResponseEntity<Mono<Response>> handleNoSuchAlgorithmException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.INTERNAL_SERVER_ERROR.getMessage()).code(GatewayError.INTERNAL_SERVER_ERROR.getCode()).build()).build()));
    }
    @ExceptionHandler(NoSuchProviderException.class)
    public ResponseEntity<Mono<Response>> handleNoSuchProviderException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.HSPA_FAILED.getMessage()).code(GatewayError.HSPA_FAILED.getCode()).build()).build()));
    }
    @ExceptionHandler(SignatureException.class)
    public ResponseEntity<Mono<Response>> handleSignatureException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.INVALID_SIGNATURE.getMessage()).code(GatewayError.INVALID_SIGNATURE.getCode()).build()).build()));
    }

    @ExceptionHandler(InvalidKeySpecException.class)
    public ResponseEntity<Mono<Response>> handleInvalidKeySpecException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.HSPA_FAILED.getMessage()).code(GatewayError.HSPA_FAILED.getCode()).build()).build()));
    }


    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Response> handleIllegalArgumentsException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.HSPA_FAILED.getMessage()).code(GatewayError.HSPA_FAILED.getCode()).build()).build());
    }

    @ExceptionHandler(NullPointerException.class)
    public ResponseEntity<Response> handleNullPointerException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.HSPA_FAILED.getMessage()).code(GatewayError.HSPA_FAILED.getCode()).build()).build());
    }

    @ExceptionHandler(HspaException.class)
    public ResponseEntity<Response> handleInternalServerError(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.INTERNAL_SERVER_ERROR.getMessage()).code(GatewayError.INTERNAL_SERVER_ERROR.getCode()).build()).build());
    }

    @ExceptionHandler(AuthHeaderNotFoundError.class)
    public ResponseEntity<Response> handleAuthHeaderNotFoundError(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.AUTH_HEADER_NOT_FOUND.getMessage()).code(GatewayError.AUTH_HEADER_NOT_FOUND.getCode()).build()).build());
    }

    @ExceptionHandler(HeaderVerificationFailedError.class)
    public ResponseEntity<Response> handleHeaderVerificationFailedError(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.HEADER_VERFICATION_FAILED.getMessage()).code(GatewayError.HEADER_VERFICATION_FAILED.getCode()).build()).build());
    }

    @ExceptionHandler(LookupException.class)
    public ResponseEntity<Mono<Response>> handleLookupError(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.LOOKUP_FAILED.getMessage()).code(GatewayError.LOOKUP_FAILED.getCode()).build()).build()));
    }

    @ExceptionHandler(InvalidKeyError.class)
    public ResponseEntity<Mono<Response>> handleInvalidKeyError(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Mono.just(Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(Error.builder().message(GatewayError.INVALID_KEY.getMessage()).code(GatewayError.INVALID_KEY.getCode()).build()).build()));
    }


    private ResponseEntity<Response> handleInvalidRequestException(Exception ex) {
        LOGGER.error("ControllerAdvice::error:: {}", ex.getMessage());


        Error err = new Error(String.valueOf(GatewayError.INVALID_REQUEST.getCode()), ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
    }

    private ResponseEntity<Response> handleLookupException() {

        LOGGER.error("Lookup call failed ::");
        Error err = new Error(String.valueOf(GatewayError.INTERNAL_SERVER_ERROR.getCode()), GatewayError.INTERNAL_SERVER_ERROR.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
    }

    private ResponseEntity<Response> handleJsonProcessorException() {

        LOGGER.error("Invalid JSON failed ::");
        Error err = new Error(String.valueOf(GatewayError.INVALID_JSON_ERROR.getCode()), GatewayError.INVALID_JSON_ERROR.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
               Response.builder().message(MessageAck.builder().ack(Ack.builder().status("NACK").build()).build()).error(err).build());
    }
}
