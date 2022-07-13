package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Data
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class MessagesDTO extends ServiceResponseDTO {
    private String contentId;
    private String sender;
    private String receiver;
    private String contentValue;
    private String time;
    private String userName;
    private String image;
}
