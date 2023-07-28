package in.gov.abdm.uhi.discovery.exception;

import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Response;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.support.WebExchangeBindException;

@ControllerAdvice
public class ValidationHandler {
    @ExceptionHandler(WebExchangeBindException.class)
    public ResponseEntity<Response> handleException(WebExchangeBindException e) {
        var errors = e.getBindingResult().getAllErrors().stream().map(DefaultMessageSourceResolvable::getDefaultMessage)
                .toList();

        MessageAck message = MessageAck.builder().ack(Ack.builder().status("NACK").build()).build();
        Response response = Response.builder().message(message).error(Error.builder().code(HttpStatus.BAD_REQUEST.value() + "")
                .message(errors.toString()).type(HttpStatus.BAD_REQUEST.name()).build()).build();

        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

    }

}