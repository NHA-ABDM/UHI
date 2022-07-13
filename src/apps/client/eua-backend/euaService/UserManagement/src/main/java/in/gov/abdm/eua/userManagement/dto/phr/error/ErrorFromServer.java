package in.gov.abdm.eua.userManagement.dto.phr.error;



import lombok.Data;

@Data
public class ErrorFromServer {
    private ErrorClass error;

    @Data
    public class ErrorClass {
        private String code;
        private String message;
    }
}
