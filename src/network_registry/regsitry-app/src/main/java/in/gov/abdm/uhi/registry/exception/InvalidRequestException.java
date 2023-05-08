package in.gov.abdm.uhi.registry.exception;

public class InvalidRequestException extends GatewayException {

    private static final long serialVersionUID = 1L;

    public InvalidRequestException(String message) {
        super(message);
    }


}
