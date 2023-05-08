package in.gov.abdm.uhi.registry.exception;

public class HeaderVerificationFailedError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public HeaderVerificationFailedError( String message) {
        super(message);
    }

}
