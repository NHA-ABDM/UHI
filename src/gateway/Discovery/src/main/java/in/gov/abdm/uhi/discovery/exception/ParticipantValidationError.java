package in.gov.abdm.uhi.discovery.exception;

public class ParticipantValidationError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public ParticipantValidationError( String message) {
        super(message);
    }

}
