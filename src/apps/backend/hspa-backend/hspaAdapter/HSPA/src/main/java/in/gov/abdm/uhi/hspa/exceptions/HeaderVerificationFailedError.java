package in.gov.abdm.uhi.hspa.exceptions;

public class HeaderVerificationFailedError extends HspaException {

    private static final long serialVersionUID = 1L;

    public HeaderVerificationFailedError( String message) {
        super(message);
    }

}
