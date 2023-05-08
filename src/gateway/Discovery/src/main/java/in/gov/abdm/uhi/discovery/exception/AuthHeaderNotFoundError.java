package in.gov.abdm.uhi.discovery.exception;

public class AuthHeaderNotFoundError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public AuthHeaderNotFoundError( String message) {
        super(message);
    }

}
