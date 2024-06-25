package in.gov.abdm.eua.service.exceptions;

public class LookupException extends GatewayException {

    private static final long serialVersionUID = 1L;

    public LookupException( String message) {
        super(message);
    }

}
