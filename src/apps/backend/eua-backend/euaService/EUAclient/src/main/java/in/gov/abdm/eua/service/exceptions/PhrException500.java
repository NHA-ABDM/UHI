package in.gov.abdm.eua.service.exceptions;

public class PhrException500 extends RuntimeException {
    public PhrException500(String errorMessage) {
        super(errorMessage);
    }
}