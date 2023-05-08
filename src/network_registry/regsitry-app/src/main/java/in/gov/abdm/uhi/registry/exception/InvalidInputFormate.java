package in.gov.abdm.uhi.registry.exception;

public class InvalidInputFormate extends RuntimeException{

	
	private static final long serialVersionUID = 1L;

	public InvalidInputFormate() {
		super();
	}

	public InvalidInputFormate(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public InvalidInputFormate(String message, Throwable cause) {
		super(message, cause);
	}

	public InvalidInputFormate(String message) {
		super(message);
	}

}
