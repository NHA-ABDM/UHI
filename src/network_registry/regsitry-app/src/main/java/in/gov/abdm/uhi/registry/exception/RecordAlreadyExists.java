package in.gov.abdm.uhi.registry.exception;

public class RecordAlreadyExists extends RuntimeException{

	private static final long serialVersionUID = 1L;

	public RecordAlreadyExists() {
		super();
	}

	public RecordAlreadyExists(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public RecordAlreadyExists(String message, Throwable cause) {
		super(message, cause); 
	}

	public RecordAlreadyExists(String message) {
		super(message);
	}

}
