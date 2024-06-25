package in.gov.abdm.eua.service.exceptions;

public class HeaderVerificationFailedError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public HeaderVerificationFailedError( String message) {
        super(message);
    }

}
