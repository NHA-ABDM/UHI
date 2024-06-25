package in.gov.abdm.eua.service.exceptions;

public class AuthHeaderNotFoundError extends EuaException {

    private static final long serialVersionUID = 1L;

    public AuthHeaderNotFoundError( String message) {
        super(message);
    }

}
