package in.gov.abdm.uhi.discovery.utility;

import static in.gov.abdm.uhi.discovery.dto.ErrorCode.HSPA_FAILED;
import static in.gov.abdm.uhi.discovery.dto.ErrorCode.INVALID_REQUEST;
import static in.gov.abdm.uhi.discovery.dto.ErrorCode.UNKNOWN_ERROR_OCCURRED;

import org.springframework.http.HttpStatus;

import in.gov.abdm.uhi.discovery.dto.Error;
import in.gov.abdm.uhi.discovery.dto.ErrorRepresentation;
import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
public class GatewayError extends Throwable {
	
	private final HttpStatus httpStatus;
    private final ErrorRepresentation error;
    
    public GatewayError(HttpStatus httpStatus, ErrorRepresentation errorRepresentation) {
        this.httpStatus = httpStatus;
        error = errorRepresentation;
    }
    
    public static GatewayError invalidRequest() {
        return new GatewayError(HttpStatus.NOT_FOUND,
                new ErrorRepresentation(new Error(INVALID_REQUEST, "Invalid Request")));   
    }
    
    public static GatewayError internalServerError(String message) {
        return new GatewayError(HttpStatus.INTERNAL_SERVER_ERROR,
                new ErrorRepresentation(new Error(UNKNOWN_ERROR_OCCURRED, message)));
    }
    
    public static GatewayError HSPAError() {
        return new GatewayError(HttpStatus.INTERNAL_SERVER_ERROR,
                new ErrorRepresentation(new Error(HSPA_FAILED, "HSPA Failure")));
    }
   
}
