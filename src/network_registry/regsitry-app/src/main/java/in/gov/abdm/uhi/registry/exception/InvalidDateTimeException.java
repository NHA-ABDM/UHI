package in.gov.abdm.uhi.registry.exception;

public class InvalidDateTimeException extends RuntimeException{

	private static final long serialVersionUID = 1L;

	public InvalidDateTimeException() {
		super();
	}

	public InvalidDateTimeException(String message, Throwable cause, boolean enableSuppression,
			boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public InvalidDateTimeException(String message, Throwable cause) {
		super(message, cause);
	}

	public InvalidDateTimeException(String message) {
		super(message);
	}

}
