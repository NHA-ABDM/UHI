package in.gov.abdm.uhi.discovery.utility;

import static in.gov.abdm.uhi.discovery.entity.ErrorCode.HSPA_FAILED;
import static in.gov.abdm.uhi.discovery.entity.ErrorCode.INVALID_REQUEST;
import static in.gov.abdm.uhi.discovery.entity.ErrorCode.UNKNOWN_ERROR_OCCURRED;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;

import in.gov.abdm.uhi.discovery.entity.Error;
import in.gov.abdm.uhi.discovery.entity.ErrorRepresentation;
import lombok.Getter;
import lombok.ToString;
@Getter
@ToString
public class GatewayError extends Throwable {
	
	private static final Logger LOGGER = LoggerFactory.getLogger(GatewayError.class);

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
