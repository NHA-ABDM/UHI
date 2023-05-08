package in.gov.abdm.uhi.discovery.exception;

public class InvalidKeyError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public InvalidKeyError( String message) {
        super(message);
    }

}
