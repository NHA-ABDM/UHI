package in.gov.abdm.uhi.EUABookingService.exceptions;
public class GenericCustomException extends RuntimeException {
   

	public GenericCustomException(String message) {
        super(message);
    }

    public GenericCustomException(String message, Throwable cause) {
        super(message, cause);
    }
}