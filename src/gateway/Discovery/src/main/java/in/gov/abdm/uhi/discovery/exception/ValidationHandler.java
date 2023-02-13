package in.gov.abdm.uhi.discovery.exception;

import java.util.stream.Collectors;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.support.WebExchangeBindException;
import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Response;

@ControllerAdvice
public class ValidationHandler {
	@ExceptionHandler(WebExchangeBindException.class)
	public ResponseEntity<Response> handleException(WebExchangeBindException e) {
		var errors = e.getBindingResult().getAllErrors().stream().map(DefaultMessageSourceResolvable::getDefaultMessage)
				.collect(Collectors.toList());
		Response response = new Response();
		MessageAck message = new MessageAck();
		Error error = new Error();
		error.setCode(HttpStatus.BAD_REQUEST.value() + "");
		error.setMessage(errors.toString());
		//error.setPath(e.getMessage().);
		error.setType(HttpStatus.BAD_REQUEST.name());
		Ack ack = new Ack();
		ack.setStatus("NACK");
		message.setAck(ack);
		response.setError(error);
		response.setMessage(message);
		return new ResponseEntity<Response>(response,HttpStatus.BAD_REQUEST) ;

	}

}