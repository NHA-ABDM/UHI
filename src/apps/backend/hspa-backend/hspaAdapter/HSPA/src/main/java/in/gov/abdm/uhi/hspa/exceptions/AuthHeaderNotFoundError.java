package in.gov.abdm.uhi.hspa.exceptions;

public class AuthHeaderNotFoundError extends HspaException {

    private static final long serialVersionUID = 1L;

    public AuthHeaderNotFoundError( String message) {
        super(message);
    }

}
