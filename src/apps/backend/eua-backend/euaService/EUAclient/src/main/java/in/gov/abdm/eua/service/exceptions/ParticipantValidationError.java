package in.gov.abdm.eua.service.exceptions;

public class ParticipantValidationError extends GatewayException {

    private static final long serialVersionUID = 1L;

    public ParticipantValidationError( String message) {
        super(message);
    }

}
