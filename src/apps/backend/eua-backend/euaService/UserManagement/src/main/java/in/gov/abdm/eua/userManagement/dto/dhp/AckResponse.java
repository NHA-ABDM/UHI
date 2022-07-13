package in.gov.abdm.eua.userManagement.dto.dhp;



import lombok.Data;

@Data
public class AckResponse {
    private MessageResponse message;
    private Error error;
}
