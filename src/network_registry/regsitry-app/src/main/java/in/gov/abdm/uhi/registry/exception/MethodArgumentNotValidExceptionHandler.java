package in.gov.abdm.uhi.registry.exception;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.WebRequest;

import in.gov.abdm.uhi.registry.dto.ErrorDetails;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class MethodArgumentNotValidExceptionHandler{
	@ExceptionHandler(MethodArgumentNotValidException.class)
	@ResponseStatus(code = HttpStatus.BAD_REQUEST)
	@ResponseBody
	public  ResponseEntity<ErrorDetails> handleMethodArgumentNotValidException(MethodArgumentNotValidException exception, WebRequest webRequest) {
		BindingResult result = exception.getBindingResult();

		final List<String> errorList = new ArrayList<>();
		result.getFieldErrors().forEach((fieldError)-> {
			errorList.add(fieldError.getDefaultMessage());
		});
		result.getGlobalErrors().forEach((fieldError) -> {
			errorList.add(fieldError.getDefaultMessage());
		});
		
		ErrorDetails errorDetails = new ErrorDetails();
		errorDetails.setMessage(errorList.toString());
		errorDetails.setPath(webRequest.getDescription(false));
		errorDetails.setStatus(HttpStatus.BAD_REQUEST.toString());
		errorDetails.setTimestamp(new Date());
		return new ResponseEntity<>(errorDetails, HttpStatus.BAD_REQUEST);
	}
	

}
