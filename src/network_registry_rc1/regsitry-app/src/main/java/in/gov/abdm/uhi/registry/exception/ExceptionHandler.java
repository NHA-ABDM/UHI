package in.gov.abdm.uhi.registry.exception;

import java.util.Date;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import in.gov.abdm.uhi.registry.dto.ErrorDetails;

@ControllerAdvice
public class ExceptionHandler {
	@org.springframework.web.bind.annotation.ExceptionHandler(ResourceNotFoundException.class)
	public ResponseEntity<ErrorDetails> handleResourceNotFoundException(ResourceNotFoundException exception,
			WebRequest webRequest) {
		ErrorDetails errorDetails = new ErrorDetails();
		errorDetails.setMessage(exception.getMessage());
		errorDetails.setStatus(HttpStatus.NOT_FOUND.toString());
		errorDetails.setPath(webRequest.getDescription(false));
		errorDetails.setTimestamp(new Date());
		return new ResponseEntity<>(errorDetails, HttpStatus.NOT_FOUND);
	}

	@org.springframework.web.bind.annotation.ExceptionHandler(RecordAlreadyExists.class)
	public ResponseEntity<ErrorDetails> recordExistsException(RecordAlreadyExists exception,
			WebRequest webRequest) {
		ErrorDetails errorDetails = new ErrorDetails();
		errorDetails.setMessage(exception.getMessage());
		errorDetails.setPath(webRequest.getDescription(false));
		errorDetails.setStatus(HttpStatus.FOUND.toString());
		errorDetails.setTimestamp(new Date());
		return new ResponseEntity<>(errorDetails, HttpStatus.FOUND);
	}

	
	@org.springframework.web.bind.annotation.ExceptionHandler(InvalidDateTimeException.class)
	public ResponseEntity<ErrorDetails> invalidDateTime(InvalidDateTimeException exception,
			WebRequest webRequest) {
		ErrorDetails errorDetails = new ErrorDetails();
		errorDetails.setMessage(exception.getMessage());
		errorDetails.setPath(webRequest.getDescription(false));
		errorDetails.setStatus(HttpStatus.BAD_REQUEST.toString());
		errorDetails.setTimestamp(new Date());
		return new ResponseEntity<>(errorDetails, HttpStatus.FOUND);
	}

	
}
