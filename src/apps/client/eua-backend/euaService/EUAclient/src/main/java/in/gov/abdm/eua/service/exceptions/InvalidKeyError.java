package in.gov.abdm.eua.service.exceptions;

public class InvalidKeyError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public InvalidKeyError( String message) {
        super(message);
    }

}
